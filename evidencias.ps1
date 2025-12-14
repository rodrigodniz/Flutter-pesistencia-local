try {
  chcp 65001 | Out-Null
} catch {}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

function Step($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "OK: $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "AVISO: $msg" -ForegroundColor Yellow }
function Fail($msg) { Write-Host "ERRO: $msg" -ForegroundColor Red; exit 1 }

function Assert-Command($cmd) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    Fail "Comando '$cmd' não encontrado. Instale/ative e tente novamente."
  }
}

# ------------------------------
# 0) Pré-checks
# ------------------------------
Step "0) Pré-requisitos"
Assert-Command docker
Assert-Command node
Assert-Command npm
Ok "Docker / Node / NPM disponíveis"

# ------------------------------
# 1) Subir LocalStack
# ------------------------------
Step "1) Subindo LocalStack (S3 simulado)"
if (-not (Test-Path ".\infra\docker-compose.yml")) {
  Fail "Não encontrei .\infra\docker-compose.yml. Execute na raiz do projeto."
}

Push-Location .\infra
docker compose up -d | Out-Host
Pop-Location

Start-Sleep -Seconds 6

$ps = docker ps --format "{{.Names}} {{.Status}}" | Select-String "localstack"
if (-not $ps) { Fail "Container 'localstack' não está rodando." }
Ok "Container localstack está rodando"

# ------------------------------
# 2) Validar bucket
# ------------------------------
Step "2) Validando bucket S3 (LocalStack)"
$buckets = docker exec localstack awslocal s3 ls
$buckets | Out-Host

if ($buckets -notmatch "shopping-images") {
  Warn "Bucket 'shopping-images' não encontrado. Criando..."
  docker exec localstack awslocal s3 mb s3://shopping-images | Out-Host
  $buckets = docker exec localstack awslocal s3 ls
}

if ($buckets -notmatch "shopping-images") { Fail "Bucket 'shopping-images' não foi encontrado/criado." }
Ok "Bucket 'shopping-images' existe"

Write-Host "`nObjetos ANTES do upload:" -ForegroundColor Gray
docker exec localstack awslocal s3 ls s3://shopping-images | Out-Host

# ------------------------------
# 3) Subir backend
# ------------------------------
Step "3) Subindo backend (Media Service)"
if (-not (Test-Path ".\backend\media-service\package.json")) {
  Fail "Não encontrei .\backend\media-service\package.json."
}

Push-Location .\backend\media-service
if (-not (Test-Path ".\node_modules")) {
  Warn "node_modules não encontrado. Rodando npm install (primeira execução)..."
  npm install | Out-Host
}

Ok "Abrindo Media Service em uma nova janela (mantém rodando)"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; npm run dev"
Pop-Location

# dá um tempo pro servidor levantar
Start-Sleep -Seconds 4
Ok "Backend iniciado (ver janela do Node para logs)"

# ------------------------------
# 4) Upload automático SEM depender de arquivo
# ------------------------------
Step "4) Upload automático (usando imagem de evidência na raiz)"

# Procura uma imagem na raiz do projeto (prioridade: evidencia.png > evidencia.jpg)
$imgPng = Join-Path (Get-Location) "evidencia.png"
$imgJpg = Join-Path (Get-Location) "evidencia.jpg"

$imgPath = $null
$mimeType = $null
$ext = $null

if (Test-Path $imgPng) {
  $imgPath = $imgPng
  $mimeType = "image/png"
  $ext = "png"
} elseif (Test-Path $imgJpg) {
  $imgPath = $imgJpg
  $mimeType = "image/jpeg"
  $ext = "jpg"
}

if ($imgPath) {
  Ok "Arquivo encontrado: $imgPath"
  $bytes = [System.IO.File]::ReadAllBytes($imgPath)
  $base64 = [Convert]::ToBase64String($bytes)

  $body = @{
    fileName   = "evidencia_$(Get-Date -Format yyyyMMdd_HHmmss).$ext"
    mimeType   = $mimeType
    base64Data = $base64
  } | ConvertTo-Json

  $resp = Invoke-RestMethod -Method Post -Uri "http://localhost:3001/upload" -ContentType "application/json" -Body $body
  Ok "Upload concluído"
  Write-Host "`nRetorno do backend:" -ForegroundColor Gray
  $resp | Format-List | Out-Host

  Write-Host "`nObjetos DEPOIS do upload:" -ForegroundColor Gray
  docker exec localstack awslocal s3 ls s3://shopping-images | Out-Host

  Write-Host "`nURL do objeto (opcional abrir no navegador):" -ForegroundColor Gray
  Write-Host $resp.url -ForegroundColor White
} else {
  Warn "Não encontrei evidencia.png nem evidencia.jpg na raiz. Fazendo upload fallback (1x1 PNG)..."

  $base64Png1x1 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMB/Yo9W0cAAAAASUVORK5CYII="
  $body = @{
    fileName   = "evidencia_$(Get-Date -Format yyyyMMdd_HHmmss).png"
    mimeType   = "image/png"
    base64Data = $base64Png1x1
  } | ConvertTo-Json

  $resp = Invoke-RestMethod -Method Post -Uri "http://localhost:3001/upload" -ContentType "application/json" -Body $body
  Ok "Upload concluído (fallback)"
  docker exec localstack awslocal s3 ls s3://shopping-images | Out-Host
}
