FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy app source
COPY . .

# Expose port
EXPOSE 7860

# Hugging Face Spaces expects port 7860
ENV PORT=7860

# Start server
CMD ["node", "server.js"]
