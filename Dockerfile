# Use official Node.js LTS slim image
FROM node:20-slim

# Set working directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy app source
COPY . .

# Expose port
EXPOSE 3000

# Use non-root user for security
USER node

# Start the app
CMD ["node", "app.js"] 