FROM node:18.14
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY index.js /app/
COPY views /app/views
CMD [ "node", "index.js" ]
