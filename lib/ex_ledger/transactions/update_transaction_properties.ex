defmodule ExLedger.Transactions.UpdateTransactionProperties do
  @moduledoc """
  Updates the transactions's properties.
  """
  alias ExLedger.Transactions.{FetchTransaction, Transaction, UpdateTransaction}
  alias __MODULE__

  @type params :: %{
          required(:properties) => map(),
          required(:transaction_id) => non_neg_integer()
        }

  @spec execute(params :: UpdateTransactionProperties.params()) ::
          {:ok, Transaction.t()} | {:error, :transaction_not_found | Ecto.Changeset.t()}
  def execute(params) do
    case FetchTransaction.execute(params.transaction_id) do
      {:ok, transaction} ->
        UpdateTransaction.execute(%{properties: params.properties}, transaction)

      error ->
        error
    end
  end
end
