defmodule ExLedger.Enums.AccountStatus do
  @moduledoc """
  Account status enum.
  """

  use EctoEnum,
    type: :account_status,
    enums: Application.compile_env!(:ex_ledger, :account_statuses)
end
