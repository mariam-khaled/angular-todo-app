# Stage 1: Build
FROM node:10-alpine as build-step
RUN mkdir -p /app
WORKDIR /app
COPY package.json /app
RUN npm install
COPY . /app
RUN npm run build --prod

# Stage 2: Unit Testing
FROM node:10

  # Install Chromium.
RUN \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
  apt-get update && \
  apt-get install -y google-chrome-stable && \
  rm -rf /var/lib/apt/lists/*

  # Define working directory.
WORKDIR /data

  # Define default command.
COPY . /data

RUN apt install -y python make g++

RUN npm i

CMD [ "./node_modules/@angular/cli/bin/ng", "test" ]

# Stage 3: E2E Testing
CMD [ "./node_modules/@angular/cli/bin/ng", "e2e" ]

# Stage 4: Deploy
FROM nginx:1.17.1-alpine
COPY --from=build-step /app/docs /usr/share/nginx/html
