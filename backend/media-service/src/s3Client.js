const AWS = require("aws-sdk");

const S3_ENDPOINT = process.env.S3_ENDPOINT || "http://localhost:4566";
const AWS_REGION = process.env.AWS_REGION || "us-east-1";
const BUCKET_NAME = process.env.BUCKET_NAME || "shopping-images";

const s3 = new AWS.S3({
  endpoint: S3_ENDPOINT,
  region: AWS_REGION,
  s3ForcePathStyle: true, // necessário pro LocalStack
  accessKeyId: process.env.AWS_ACCESS_KEY_ID || "test",
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || "test"
});

async function ensureBucketExists() {
  try {
    await s3.headBucket({ Bucket: BUCKET_NAME }).promise();
    console.log(`[S3] Bucket OK: ${BUCKET_NAME}`);
  } catch (err) {
    const code = err.statusCode || err.code;
    if (code === 404 || code === "NotFound" || code === "NoSuchBucket") {
      console.log(`[S3] Bucket não existe, criando: ${BUCKET_NAME}`);
      await s3.createBucket({ Bucket: BUCKET_NAME }).promise();
      console.log(`[S3] Bucket criado: ${BUCKET_NAME}`);
    } else {
      console.error("[S3] Erro ao verificar/criar bucket:", err);
      throw err;
    }
  }
}

async function uploadBase64Image({ fileName, mimeType, base64Data }) {
  const buffer = Buffer.from(base64Data, "base64");

  await s3
    .putObject({
      Bucket: BUCKET_NAME,
      Key: fileName,
      Body: buffer,
      ContentType: mimeType
    })
    .promise();

  // URL simples (para demo/retorno no app)
  const url = `${S3_ENDPOINT}/${BUCKET_NAME}/${encodeURIComponent(fileName)}`;
  return { bucket: BUCKET_NAME, key: fileName, url };
}

module.exports = {
  BUCKET_NAME,
  ensureBucketExists,
  uploadBase64Image
};
