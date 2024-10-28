defmodule ExLedger.Transactions.FailWithdrawal do
  @moduledoc """
  Marks the withdrawal transaction as failed and credits the account.
  """
  alias ExLedger.Transactions.{
    CreditAccount,
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

  @spec execute(FailWithdrawal.params()) ::
          {:ok, Transaction.t()}
          | {:error, :transaction_not_found | :invalid_transaction_status | Ecto.Changeset.t()}
  def execute(params) do
    Repo.transaction(fn ->
      with {:ok, transaction} <-
             LockTransaction.execute(params.transaction_id),
           :ok <- ValidateTransactionStatus.execute(transaction.status, :created),
           {:ok, account} <- CreditAccount.execute(transaction),
           {:ok, failed_transaction} <-
             UpdateTransaction.execute(
               %{status: :failed, properties: Map.get(params, :properties, %{})},
               transaction
             ) do
        {:ok, Map.replace!(failed_transaction, :account, account)}
      end
    end)
  end
end