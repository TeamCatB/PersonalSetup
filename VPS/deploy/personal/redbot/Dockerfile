FROM python:3.11-slim

ARG BOT_NAME
ENV BOT_NAME $BOT_NAME

WORKDIR /app

COPY install.sh .

RUN chmod +x install.sh

RUN /app/install.sh

CMD source ~/redenv/bin/activate | redbot $BOT_NAME