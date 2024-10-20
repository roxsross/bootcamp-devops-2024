FROM node:21-alpine

WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY . .
RUN npm run build
EXPOSE 5000
CMD ["npm", "start"]