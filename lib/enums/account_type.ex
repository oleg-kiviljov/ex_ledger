defmodule ExLedger.Enums.AccountType do
  @moduledoc """
  Account type enum.
  """

  use EctoEnum,
    type: :account_type,
    enums: Keyword.keys(Application.compile_env!(:ex_ledger, :account_types))
end
