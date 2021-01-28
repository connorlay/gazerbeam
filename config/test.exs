use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :gazerbeam, Gazerbeam.Repo,
  username: "gazerbeam",
  password: "gazerbeam",
  database: "gazerbeam_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gazerbeam, GazerbeamWeb.Endpoint,
  http: [port: 4002],
  server: false

# Read GitHub credentials from local environment
config :gazerbeam, Gazerbeam.Client,
  impl: Gazerbeam.Client.GitHubMock,
  token: "github_token"

# Do not run any jobs during test
config :gazerbeam, Gazerbeam.Scheduler, jobs: []

# Print only warnings and errors during test
config :logger, level: :warn
