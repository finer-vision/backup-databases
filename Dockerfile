FROM alpine:3.9

RUN apk --update add --no-cache nodejs mysql-client

ADD package*.json ./
ADD index.js index.js
RUN npm install
RUN node index.js
