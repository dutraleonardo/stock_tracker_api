FROM elixir:1.12-alpine as build

# install build dependencies
RUN apk add --no-cache build-base npm git python3

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

COPY priv priv
RUN mix phx.digest

# compile and build release
COPY lib lib
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix do compile, release

# prepare release image
FROM alpine:3.16 AS app
# added bash and postgresql-client for entrypoint.sh
RUN apk add --no-cache openssl ncurses-libs bash postgresql-client

RUN apk upgrade --no-cache && \
    apk add --no-cache bash openssl libgcc libstdc++ ncurses-libs

ENV USER=finiam
ENV HOME=/home/"${USER}"
ENV APP_DIR="${HOME}/app"

# Creates an unprivileged user to be used exclusively to run the Phoenix app
RUN \
  addgroup \
   -g 1000 \
   -S "${USER}" && \
  adduser \
   -s /bin/sh \
   -u 1000 \
   -G "${USER}" \
   -h "${HOME}" \
   -D "${USER}" && \
  su "${USER}" sh -c "mkdir ${APP_DIR}"


# Everything from this line onwards will run in the context of the unprivileged user.
USER "${USER}"

WORKDIR "${APP_DIR}"

COPY --from=build --chown="${USER}":"${USER}" /app/_build/prod/rel/stock_tracker_api ./
COPY entrypoint.sh .

CMD ["bash", "/app/entrypoint.sh"]
