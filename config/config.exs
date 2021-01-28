# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

require Logger

config :gazerbeam,
  ecto_repos: [Gazerbeam.Repo]

# Configures the endpoint
config :gazerbeam, GazerbeamWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Y8NceJRfaqbQ83yN8NYD4lQ7oWfCMujelxjcLUPHyM+L9qUwGWGgaqwuSs6OSnPH",
  render_errors: [view: GazerbeamWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Gazerbeam.PubSub,
  live_view: [signing_salt: "vApFkszS"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Read GitHub personal token from system environment
github_token = System.get_env("GITHUB_TOKEN")

if github_token do
  config :gazerbeam, Gazerbeam.Client, access_token: github_token
else
  Logger.warn("GITHUB_TOKEN environment variable not set")
end

# Configure GitHub API client
config :gazerbeam, Gazerbeam.Client, impl: Gazerbeam.Client.GitHub

# Ensure Tentacat fetches starred_at field
# See: https://docs.github.com/en/rest/reference/activity#custom-media-types-for-starring
config(:tentacat, :extra_headers, [{"Accept", "application/vnd.github.v3.star+json"}])

# Run GitHub stargazer sync every day at mignight
config :gazerbeam, Gazerbeam.Scheduler,
  jobs: [{"@daily", {Gazerbeam.GitHub, :sync_all_repository_stargazers, []}}]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
