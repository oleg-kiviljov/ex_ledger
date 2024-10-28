defmodule ExLedger.Enums.TransactionType do
  @moduledoc """
  Transaction type enum.
  """

  use EctoEnum,
    type: :transaction_type,
    enums: Keyword.keys(Application.compile_env!(:ex_ledger, :transaction_types))
end
