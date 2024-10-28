defmodule ExLedger.Transactions.TransactionQuery do
  @moduledoc """
  Transaction queries.
  """
  alias ExLedger.Transactions.Transaction

  import Ecto.Query

  def get(query \\ base(), transaction_id) do
    where(query, [t], t.id == ^transaction_id)
  end

  def with_lock(query \\ base(), transaction_id) do
    query
    |> get(transaction_id)
    |> lock("FOR UPDATE")
  end

  defp base, do: Transaction
end
