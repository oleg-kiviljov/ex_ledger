defmodule ExLedger.Enums.TransactionStatus do
  @moduledoc """
  Transaction status enum.
  """

  use EctoEnum,
    type: :transaction_status,
    enums: ~w(created confirmed failed)a
end
