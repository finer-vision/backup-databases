FROM alpine:3.12

RUN apk --update add --no-cache nodejs npm mysql-client

ADD package*.json ./
ADD index.js index.js
RUN npm install
RUN node index.js
