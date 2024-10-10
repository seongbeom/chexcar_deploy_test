# Stage 1: Build the application
FROM node:20.18.0-alpine AS builder

# Set working directory
WORKDIR /usr/src/app

# Install NestJS CLI for development
RUN npm install -g @nestjs/cli

# Install dependencies
COPY package*.json ./
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
COPY --from=builder /usr/src/app/.env.production ./

# Install only production dependencies
RUN npm ci --omit=dev