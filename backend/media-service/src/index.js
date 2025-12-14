const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");

const { ensureBucketExists, uploadBase64Image, BUCKET_NAME } = require("./s3Client");

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(bodyParser.json({ limit: "15mb" })); // base64 pode ser grande

app.get("/health", (req, res) => {
  res.json({ status: "ok", service: "media-service", bucket: BUCKET_NAME });
});

/**
 * POST /upload
 * Body JSON:
 * {
 *   "fileName": "task_123.jpg",
 *   "mimeType": "image/jpeg",
 *   "base64Data": "<...>"
 * }
 */
app.post("/upload", async (req, res) => {
  try {
    const { fileName, mimeType, base64Data } = req.body || {};

    if (!fileName || !mimeType || !base64Data) {
      return res.status(400).json({
        error: "Campos obrigatórios: fileName, mimeType, base64Data"
      });
    }

    // validação simples (evita nomes estranhos)
    if (typeof fileName !== "string" || fileName.length < 3) {
      return res.status(400).json({ error: "fileName inválido" });
    }

    const result = await uploadBase64Image({ fileName, mimeType, base64Data });
    return res.status(201).json({
      message: "Imagem enviada com sucesso!",
      ...result
    });
  } catch (err) {
    console.error("Erro no upload:", err);
    return res.status(500).json({ error: "Erro interno ao enviar imagem" });
  }
});

app.listen(PORT, async () => {
  console.log(`Media Service rodando em http://localhost:${PORT}`);
  await ensureBucketExists();
});
