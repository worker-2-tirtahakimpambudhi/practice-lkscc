FROM node:23-alpine AS build

ARG username="appuser"
ARG unique_id=3125

WORKDIR /app
COPY package.json package-lock.json ./

RUN npm ci  && \
    adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${unique_id}" \
    "${username}"  


COPY --chown=${username}:${username} . .

FROM gcr.io/distroless/nodejs22-debian12

ARG username="appuser"

ENV REGION="YOUR_AWS_REGION" \
    ACCESS_KEY="YOUR_AWS_KEY_ID" \
    SECRET_KEY="YOUR_AWS_SECRET_KEY" \
    SESSION_TOKEN="YOUR_AWS_SESSION_TOKEN" \
    BUCKET_NAME="YOUR_AWS_BUCKET_NAME" \
    ENDPOINT="" \
    PORT=3000

WORKDIR /app

COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group

USER root

COPY --chown=${username}:${username} --from=build /app .

USER ${username}:${username}

EXPOSE ${PORT}

CMD [ "index.js" ]