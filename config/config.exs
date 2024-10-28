import Config

config :ex_ledger,
  repo: nil,
  otp_app: nil,
  supported_currencies: [],
  account_statuses: [],
  account_types: [],
  transaction_types: []

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
