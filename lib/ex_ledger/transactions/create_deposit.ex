defmodule ExLedger.Transactions.CreateDeposit do
  @moduledoc """
  Creates a deposit transaction.
  """
  alias ExLedger.Transactions.{CreateTransaction, Transaction, TransactionType}
  alias __MODULE__

  @type params :: %{
          required(:amount) => Decimal.t(),
          required(:type) => TransactionType.t(),
          required(:properties) => map(),
          required(:account_id) => non_neg_integer()
        }

  @spec execute(params :: CreateDeposit.params()) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def execute(params) do
    CreateTransaction.execute(params)
  end
end
