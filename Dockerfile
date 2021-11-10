FROM node:12-alpine3.12

COPY package.json /package.json
COPY index.js /index.js
COPY entrypoint.sh /entrypoint.sh

RUN apk --update add --no-cache bash nodejs npm mysql-client
RUN npm install
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
