ARG BUILDER_IMAGE="hexpm/elixir:1.14.1-erlang-25.0.4-debian-bullseye-20220801-slim"
ARG RUNNER_IMAGE="debian:bullseye-20220801-slim"
ARG MIX_ENV="prod"

FROM ${BUILDER_IMAGE} as builder

ARG MIX_ENV

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="$MIX_ENV"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# copy priv folder (contains static assets)
COPY priv/ priv/

# copy assets that get compiled, e.g. by esbuild + tailwindcss
COPY assets/ assets/

# Compile the release
COPY lib/ lib/
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel/ rel/
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

ARG MIX_ENV
ARG PORT="4000"

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales curl jq \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

ARG RELEASE_NAME

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/$MIX_ENV/rel/example_system ./
RUN ln -s /app/bin/example_system /app/bin/server

USER nobody

EXPOSE "$PORT/tcp"

ENTRYPOINT [ "/app/bin/server" ]
CMD ["start"]
