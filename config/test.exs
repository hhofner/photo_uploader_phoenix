import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :photo_uploader_phoenix, PhotoUploaderPhoenix.Repo,
  database: Path.expand("../photo_uploader_phoenix_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :photo_uploader_phoenix, PhotoUploaderPhoenixWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "L1r1as8kWjwyNJFBBcsiYBLBRs48owHPS7wljngrWYi3IYV7OsCa4lN/Ojuuk/7p",
  server: false

# In test we don't send emails
config :photo_uploader_phoenix, PhotoUploaderPhoenix.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
