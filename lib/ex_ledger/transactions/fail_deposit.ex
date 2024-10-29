defmodule ExLedger.Transactions.FailDeposit do
  @moduledoc """
  Marks the deposit transaction as failed.
  """
  alias ExLedger.Transactions.{
    LockTransaction,
    Transaction,
    UpdateTransaction,
    ValidateTransactionStatus
  }

  alias ExLedger.Repo
  alias __MODULE__

  @type params :: %{
          required(:transaction_id) => non_neg_integer(),
          optional(:properties) => map()
        }

  @spec execute(FailDeposit.params()) ::
          {:ok, Transaction.t()}
          | {:error, :transaction_not_found | :transaction_already_processed | Ecto.Changeset.t()}
  def execute(params) do
    Repo.transaction(fn ->
      with {:ok, transaction} <-
             LockTransaction.execute(params.transaction_id),
           :ok <- ValidateTransactionStatus.execute(transaction.status, :created) do
        UpdateTransaction.execute(
          %{status: :failed, properties: Map.get(params, :properties, %{})},
          transaction
        )
      end
    end)
  end
end
