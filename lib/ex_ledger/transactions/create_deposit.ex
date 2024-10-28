defmodule ExLedger.Transactions.CreateDeposit do
  @moduledoc """
  Creates a deposit transaction.
  """
  alias ExLedger.Enums.TransactionType
  alias ExLedger.Transactions.{CreateTransaction, Transaction}
  alias __MODULE__

  @type params :: %{
          required(:amount) => Decimal.t(),
          required(:type) => TransactionType.t(),
          required(:properties) => map(),
          required(:account_id) => non_neg_integer()
        }

  @spec execute(CreateDeposit.params()) :: {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def execute(params) do
    CreateTransaction.execute(params)
  end
end
