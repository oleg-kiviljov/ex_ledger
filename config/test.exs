import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ex_ledger, ExLedger.TestRepo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ex_ledger_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :ex_ledger,
  ecto_repos: [ExLedger.TestRepo],
  generators: [timestamp_type: :utc_datetime]

config :ex_ledger,
  repo: ExLedger.TestRepo,
  supported_currencies: ~w(ETH BTC)a,
  account_statuses: ~w(enabled disabled)a,
  account_types: [crypto_account: ExLedger.AccountTypes.CryptoAccount],
  transaction_types: [
    crypto_deposit: ExLedger.TransactionTypes.CryptoDeposit,
    crypto_withdrawal: ExLedger.TransactionTypes.CryptoWithdrawal
  ]

# Print only warnings and errors during test
config :logger, level: :warning
