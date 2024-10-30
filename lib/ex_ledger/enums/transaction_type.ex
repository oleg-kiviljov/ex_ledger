defmodule ExLedger.Enums.TransactionType do
  @moduledoc """
  Transaction type enum.
  """
  @transaction_types Application.compile_env!(:ex_ledger, :transaction_types)
  @deprecated_transaction_types Application.compile_env(:ex_ledger, :deprecated_transaction_types, [])

  use EctoEnum,
    type: :transaction_type,
    enums: Keyword.keys(@transaction_types) ++ @deprecated_transaction_types
end
