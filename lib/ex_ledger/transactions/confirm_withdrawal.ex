defmodule ExLedger.Transactions.ConfirmWithdrawal do
  @moduledoc """
  Confirms the withdrawal transaction.
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

  @spec execute(ConfirmWithdrawal.params()) ::
          {:ok, Transaction.t()}
          | {:error, :transaction_not_found | :transaction_already_processed | Ecto.Changeset.t()}
  def execute(params) do
    Repo.transaction(fn ->
      with {:ok, transaction} <-
             LockTransaction.execute(params.transaction_id),
           :ok <- ValidateTransactionStatus.execute(transaction.status, :created) do
        UpdateTransaction.execute(
          %{status: :confirmed, properties: Map.get(params, :properties, %{})},
          transaction
        )
      end
    end)
  end
end
