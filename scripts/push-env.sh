#!/bin/bash

# S3 버킷과 파일 경로 설정
BUCKET_NAME="chexcar-api-dev"
ENV_FILE_PATH="env/.env.$NODE_ENV"

# .env 파일이 존재하는지 확인
if [ ! -f ".env" ]; then
    echo ".env file does not exist. Please create it before uploading."
    exit 1
fi

# .env 파일 업로드
echo "Uploading .env file to S3..."
aws s3 cp .env s3://$BUCKET_NAME/$ENV_FILE_PATH

# 업로드 성공 여부 확인
if [ $? -eq 0 ]; then
    echo ".env file uploaded successfully."
else
    echo "Failed to upload .env file."
    exit 1
fi