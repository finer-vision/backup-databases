FROM alpine:3.14.2

RUN apk --update add --no-cache bash binutils mysql-client

FROM amazon/aws-cli:2.0.6

RUN aws --version
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
