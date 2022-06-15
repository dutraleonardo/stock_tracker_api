FROM elixir:1.12-alpine as build

# install build dependencies
RUN apk add --no-cache build-base \
  git \
  make \
  gcc \
  libc-dev \
  python3

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

RUN mkdir /app
WORKDIR /app

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/stock_tracker_api ./
COPY entrypoint.sh .

RUN chown -R nobody: /app
USER nobody

ENV HOME=/app

CMD ["bash", "/app/entrypoint.sh"]
