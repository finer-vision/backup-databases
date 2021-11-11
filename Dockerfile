FROM alpine:3.14.2

RUN apk --update add --no-cache bash binutils mysql-client python3 py3-pip
RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir awscli

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
