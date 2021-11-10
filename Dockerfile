FROM alpine:3.12

WORKDIR /app

ADD package*.json ./
ADD index.js .
ADD entrypoint.sh .

RUN apk --update add --no-cache nodejs npm mysql-client
RUN npm install
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
