# Official Node.js runtime to be used as the base image
FROM node:20-alpine

# The working directory
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install the app dependencies
RUN npm install

# Copy the application code to the working directory
COPY . .

# Expose port 3000
EXPOSE 3000

# Define the command to run the application
CMD ["node", "igniteapp.js"]