defmodule ExLedger.Transactions.ValidateTransactionStatus do
  @moduledoc """
  Validates that the transaction can be processed.
  """
  alias ExLedger.Enums.TransactionStatus

  @spec execute(current_status :: TransactionStatus.t(), valid_status :: TransactionStatus.t()) ::
          :ok | {:error, :invalid_transaction_status}
  def execute(current_status, valid_status) do
    if current_status == valid_status do
      :ok
    else
      {:error, :invalid_transaction_status}
    end
  end
end
