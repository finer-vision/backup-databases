FROM alpine:3.9

RUN apk --update add --no-cache nodejs mysql-client

ADD index.js /index.js
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
