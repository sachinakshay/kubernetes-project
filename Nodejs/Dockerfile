# Use an official Node.js runtime as a parent image
FROM node:20

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json app.js ./

# Install app dependencies
RUN npm install

# Expose port 3000
EXPOSE 3000

#CMD ["node", "app.js"]
CMD ["node", "app.js"]














