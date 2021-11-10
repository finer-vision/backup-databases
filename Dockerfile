FROM alpine:3.9

RUN apk --update add --no-cache nodejs mysql-client

ADD index.js /index.js
RUN nodejs /index.js
