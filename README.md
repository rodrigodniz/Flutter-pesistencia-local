# Task Manager — Etapa 3
## Simulação de Cloud com LocalStack (S3)

Este projeto implementa a **Opção B – Simulação de Cloud com LocalStack (S3)**, conforme o roteiro da Etapa 3 da disciplina.

O objetivo é substituir o armazenamento de fotos apenas no dispositivo por um **armazenamento de objetos em nuvem local simulada**, utilizando o **LocalStack** para emular o serviço **Amazon S3**.

---

## Objetivo

Configurar um ambiente local que simula a AWS utilizando o **LocalStack**, permitindo que imagens enviadas pela aplicação sejam armazenadas em um bucket S3 local, em vez de ficarem apenas no dispositivo.

---

## Tecnologias Utilizadas

- **Flutter** – Aplicação mobile (persistência local e captura de foto)
- **Node.js + Express** – Backend (Media Service)
- **Docker + Docker Compose** – Infraestrutura
- **LocalStack** – Emulação local de serviços AWS
- **Amazon S3 (LocalStack)** – Armazenamento de imagens
- **AWS SDK (JavaScript)** – Comunicação com o S3
- **SQLite (sqflite)** – Persistência local no aplicativo

---

## Arquitetura da Solução

1. O usuário cria ou edita uma tarefa no aplicativo Flutter.
2. O usuário pode tirar uma foto usando a câmera do dispositivo.
3. Ao salvar a tarefa **com conexão ativa**, a imagem é enviada ao backend.
4. O backend salva a imagem no bucket **shopping-images**, no S3 simulado pelo LocalStack.
5. O backend retorna a URL da imagem salva.
6. A aplicação pode manter:
   - o caminho local da imagem (`photoPath`);
   - a URL da imagem no S3 local (`imageUrl`).

---

## Como Executar o Projeto

### 1. Subir a Infraestrutura (LocalStack)

Na pasta `infra`:

```bash
docker compose up -d
docker ps
```

O LocalStack será iniciado e o bucket `shopping-images` será criado automaticamente.

---

### 2. Verificar o Bucket S3 (via LocalStack)

Entrar no container do LocalStack:

```bash
docker exec -it localstack bash
```

Listar os buckets:

```bash
awslocal s3 ls
```

Listar os objetos do bucket:

```bash
awslocal s3 ls s3://shopping-images
```

---

### 3. Executar o Backend (Media Service)

Em outro terminal:

```bash
cd backend/media-service
npm install
npm run dev
```

Verificar se o serviço está ativo:

```bash
curl http://localhost:3001/health
```

---

### 4. Testar Upload de Imagem (PowerShell)

No Windows PowerShell, utilizando uma imagem local:

```powershell
$path = "C:\Users\Cliente\Pictures\mamaco.jpg"
$bytes = [System.IO.File]::ReadAllBytes($path)
$base64 = [Convert]::ToBase64String($bytes)

$body = @{
  fileName = "teste_$(Get-Date -Format yyyyMMdd_HHmmss).jpg"
  mimeType = "image/jpeg"
  base64Data = $base64
} | ConvertTo-Json

Invoke-RestMethod -Method Post `
  -Uri "http://localhost:3001/upload" `
  -ContentType "application/json" `
  -Body $body
```

A resposta indica sucesso no upload e retorna a URL da imagem salva.

---

### 5. Validar Imagem Salva no S3 Local

Dentro do container do LocalStack:

```bash
awslocal s3 ls s3://shopping-images
```

A imagem enviada deve aparecer listada no bucket.

---

## Endpoint Implementado

### POST `/upload`

Responsável por receber uma imagem em Base64 e armazená-la no S3 local.

#### Request (JSON)

```json
{
  "fileName": "imagem.jpg",
  "mimeType": "image/jpeg",
  "base64Data": "<BASE64>"
}
```

#### Response (201)

```json
{
  "message": "Imagem enviada com sucesso!",
  "bucket": "shopping-images",
  "key": "imagem.jpg",
  "url": "http://localhost:4566/shopping-images/imagem.jpg"
}
```

---

## Evidências

Rodar script "evidencias.ps1" presente na raiz do projeto 

=== 0) PrÃ©-requisitos ===
OK: Docker / Node / NPM disponÃ­veis

=== 1) Subindo LocalStack (S3 simulado) ===
time="2025-12-15T17:35:59-03:00" level=warning msg="C:\\Users\\Cliente\\Documents\\Persistencia flutter\\task_manager\\infra\\docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion"
 Container localstack  Running
OK: Container localstack estÃ¡ rodando

=== 2) Validando bucket S3 (LocalStack) ===
2025-12-15 20:35:29 shopping-images
OK: Bucket 'shopping-images' existe

Objetos ANTES do upload:

=== 3) Subindo backend (Media Service) ===
OK: Abrindo Media Service em uma nova janela (mantÃ©m rodando)
OK: Backend iniciado (ver janela do Node para logs)

=== 4) Upload automÃ¡tico (usando imagem de evidÃªncia na raiz) ===
OK: Arquivo encontrado: C:\Users\Cliente\Documents\Persistencia flutter\task_manager\evidencia.png
OK: Upload concluÃ­do

Retorno do backend:


message : Imagem enviada com sucesso!
bucket  : shopping-images
key     : evidencia_20251215_173612.png
url     : http://localhost:4566/shopping-images/evidencia_20251215_173612.png




Objetos DEPOIS do upload:
2025-12-15 20:36:12       8460 evidencia_20251215_173612.png

URL do objeto (opcional abrir no navegador):
http://localhost:4566/shopping-images/evidencia_20251215_173612.png

[Done] exited with code=0 in 15.867 seconds
