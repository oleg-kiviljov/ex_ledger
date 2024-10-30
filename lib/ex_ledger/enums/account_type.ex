defmodule ExLedger.Enums.AccountType do
  @moduledoc """
  Account type enum.
  """
  @account_types Keyword.keys(Application.compile_env!(:ex_ledger, :account_types))
  @deprecated_account_types Application.compile_env(:ex_ledger, :deprecated_account_types, [])

  use EctoEnum,
    type: :account_type,
    enums: @account_types ++ @deprecated_account_types
end
