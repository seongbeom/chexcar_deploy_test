# Stage 1: Build the application
FROM node:20.18.0 AS builder

# Set working directory
WORKDIR /usr/src/app

# Update package lists and install AWS CLI
RUN apt-get update && apt-get install -y awscli

# Install NestJS CLI for development
RUN npm install -g @nestjs/cli

# Install dependencies
COPY package*.json ./
COPY scripts/preinstall.sh ./scripts/preinstall.sh
# Give execute permissions to the preinstall.sh script
RUN chmod +x ./scripts/preinstall.sh

# Define build arguments for AWS credentials
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION

# Use the build arguments (optional, if needed inside the build)
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ENV AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

RUN sh ./scripts/preinstall.sh
RUN npm ci

# Copy application source code
COPY . .

# Build the application (production build)
RUN npm run build

# Stage 2: Create a production-ready image
FROM node:20.18.0-alpine

# Install PM2 globally
RUN npm install -g pm2

# Set working directory
WORKDIR /usr/src/app

# Copy only the necessary files from the build stage
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/package*.json ./
# PM2 config 파일 복사
COPY --from=builder /usr/src/app/ecosystem.config.js ./
COPY --from=builder /usr/src/app/.env ./
# COPY --from=builder /usr/src/app/scripts/* ./scripts

# Install only production dependencies
RUN npm ci --omit=dev

# Run the application
CMD ["sh", "-c", "pm2-runtime ecosystem.config.js --no-daemon"]