# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :nested,
  ecto_repos: [Nested.Repo]

# Configures the endpoint
config :nested, Nested.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nZz26TcGQc78waI3zc5vtUy0/WJseQxwH8Dg4UZbiXVsD4+t0UQqLMKh4TJH6pnA",
  render_errors: [view: Nested.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Nested.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Nested.User,
  repo: Nested.Repo,
  module: Nested,
  router: Nested.Router,
  messages_backend: Nested.Coherence.Messages,
  logged_out_url: "/",
  email_from_name: "Your Name",
  email_from_email: "yourname@example.com",
  opts: [:authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :invitable, :registerable]

config :coherence, Nested.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "your api key here"
# %% End Coherence Configuration %%

config :policy_wonk, PolicyWonk,
  policies: Nested.Policies


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
