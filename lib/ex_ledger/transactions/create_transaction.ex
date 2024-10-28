defmodule ExLedger.Transactions.CreateTransaction do
  @moduledoc """
  Creates a transaction.
  """
  alias ExLedger.Repo
  alias ExLedger.Transactions.Transaction

  @spec execute(params :: map()) :: {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def execute(params) do
    params
    |> Transaction.create_changeset()
    |> Repo.insert()
  end
end
