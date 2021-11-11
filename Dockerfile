FROM alpine:3.14.2

COPY entrypoint.sh /entrypoint.sh

RUN apk --update add --no-cache bash mysql-client python3 py3-pip
RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir awscli
RUN awscli
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
