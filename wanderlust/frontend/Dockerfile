# Use a specific version of the base image
FROM node:21-alpine

# Set the working directory
WORKDIR /app

# Copy only package.json and package-lock.json first to leverage caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the application port
EXPOSE 5173

# Command to run the application
CMD ["npm", "run", "dev", "--", "--host"]