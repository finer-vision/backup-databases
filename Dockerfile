FROM alpine:3.14.2

COPY entrypoint.sh /entrypoint.sh

RUN apk --update add --no-cache bash binutils mysql-client
RUN chmod +x /entrypoint.sh

FROM amazon/aws-cli:2.0.6

RUN aws --version

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
