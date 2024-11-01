defmodule ExLedger.Accounts.AccountCurrency do
  @moduledoc """
  Account currency enum.
  """

  use EctoEnum,
    type: :account_currency,
    enums: Application.compile_env!(:ex_ledger, :account_currencies)
end
