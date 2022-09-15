# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# Configures the endpoint
config :example_system, ExampleSystemWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CRulGglCO2Nnoo8X/DgocGTgzDvMlAZ750QCd2hfe7mIUv/jRw2MCST3fonN2c2P",
  render_errors: [view: ExampleSystemWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: ExampleSystem.PubSub,
  live_view: [signing_salt: "66Jp7PO+NlJCA1sf6mB/5WrEdicRPQmu"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  discard_threshold_for_error_logger: 10,
  handle_sasl_reports: true

config :sasl, sasl_error_logger: false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :phoenix,
  json_library: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
