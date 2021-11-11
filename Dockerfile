FROM alpine:3.14.2

COPY entrypoint.sh /entrypoint.sh

RUN apk --update add --no-cache bash mysql-client curl unzip
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/awscliv2.zip"
RUN unzip /awscliv2.zip
RUN /aws/install -i /usr/local/aws -b /usr/local/bin/aws
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
