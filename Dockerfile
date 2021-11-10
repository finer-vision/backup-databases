FROM alpine:3.12

WORKDIR /app

ADD package*.json ./
ADD index.js index.js

RUN apk --update add --no-cache nodejs npm mysql-client
RUN npm install

CMD ["node", "index.js"]
