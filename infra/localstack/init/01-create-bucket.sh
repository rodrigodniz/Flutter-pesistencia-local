#!/usr/bin/env bash
set -e

echo "[localstack init] Creating bucket shopping-images (if not exists)..."

awslocal s3api head-bucket --bucket shopping-images 2>/dev/null \
  || awslocal s3 mb s3://shopping-images

echo "[localstack init] Buckets:"
awslocal s3 ls
