FROM debian:bookworm

ARG BOT_NAME
ENV BOT_NAME

WORKDIR /app

COPY . .

RUN install.sh

CMD source ~/redenv/bin/activate | redbot $BOT_NAME