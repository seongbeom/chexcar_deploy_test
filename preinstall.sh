#!/bin/bash

# NODE_ENV가 설정되어 있지 않으면 local로 설정
if [ -z "$NODE_ENV" ]; then
    export NODE_ENV="local"
    echo "NODE_ENV is not set. Defaulting to local."
fi

# S3 버킷과 파일 경로 설정
BUCKET_NAME="chexcar-api-dev"
ENV_FILE_PATH="env/.env.$NODE_ENV"

# .env 파일 다운로드
echo "Downloading .env file from S3..."
aws s3 cp s3://$BUCKET_NAME/$ENV_FILE_PATH .env

# 다운로드 성공 여부 확인
if [ $? -eq 0 ]; then
    echo ".env file downloaded successfully."
else
    echo "Failed to download .env file."
    exit 1
fi