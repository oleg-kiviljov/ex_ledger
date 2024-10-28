defmodule ExLedger.Transactions.LockTransaction do
  @moduledoc """
  Locks the transaction for update.
  """
  alias ExLedger.Repo
  alias ExLedger.Transactions.{Transaction, TransactionQuery}

  @spec execute(transaction_id :: non_neg_integer()) ::
          {:ok, Transaction.t()} | {:error, :transaction_not_found}

  def execute(nil), do: {:error, :transaction_not_found}

  def execute(transaction_id) do
    transaction_id
    |> TransactionQuery.with_lock()
    |> Repo.one()
    |> case do
      nil -> {:error, :transaction_not_found}
      transaction -> {:ok, transaction}
    end
  end
end
