defmodule ExLedger.Accounts.AccountType do
  @moduledoc """
  Account type enum.
  """
  @account_types Application.compile_env!(:ex_ledger, :account_types)
  @deprecated_account_types Application.compile_env(:ex_ledger, :deprecated_account_types, [])

  use EctoEnum,
    type: :account_type,
    enums: Keyword.keys(@account_types) ++ @deprecated_account_types
end
