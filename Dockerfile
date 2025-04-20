FROM node:18-bullseye

WORKDIR /app

COPY angular-site/angular-bird/ ./

RUN npm install -g @angular/cli http-server && \
    npm install && \
    ng build --configuration=production

EXPOSE 4200

CMD ["http-server", "dist/wsu-hw-ng", "-p", "4200"]

