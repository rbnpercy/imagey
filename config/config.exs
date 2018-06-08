# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :imagey,
  ecto_repos: [Imagey.Repo]

# Configures the endpoint
config :imagey, ImageyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "dRzHx6HRspWiNcb8vsDcPiSk9zQo/Mgi0P6Z2VMI9seSIU/HLjYu32NqtdsgP3IM",
  render_errors: [view: ImageyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Imagey.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]


# Configure :ex_aws
config :ex_aws,
  access_key_id: "AKIAJJIQPDHXSDARCI5Q",
  secret_access_key: "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",
  s3: [
    scheme: "https://",
    host: "imagey-elixir.s3.amazonaws.com",
    region: "eu-west-2"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
