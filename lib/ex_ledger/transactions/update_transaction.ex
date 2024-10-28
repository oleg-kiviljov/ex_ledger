defmodule ExLedger.Transactions.UpdateTransaction do
  @moduledoc """
  Updates the transaction.
  """
  alias ExLedger.Repo
  alias ExLedger.Transactions.Transaction

  @spec execute(params :: map(), transaction :: Transaction.t()) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def execute(params, transaction) do
    transaction
    |> Transaction.update_changeset(params)
    |> Repo.update()
  end
end
