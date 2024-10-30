defmodule ExLedger.Transactions.ConfirmDeposit do
  @moduledoc """
  Confirms the deposit transaction and credits the account.
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

  @spec execute(params :: ConfirmDeposit.params()) ::
          {:ok, Transaction.t()}
          | {:error, :transaction_not_found | :transaction_already_processed | Ecto.Changeset.t()}
  def execute(params) do
    Repo.transaction(fn ->
      with {:ok, transaction} <-
             LockTransaction.execute(params.transaction_id),
           :ok <- ValidateTransactionStatus.execute(transaction.status, :created),
           {:ok, account} <- CreditAccount.execute(transaction),
           {:ok, confirmed_transaction} <-
             UpdateTransaction.execute(
               %{status: :confirmed, properties: Map.get(params, :properties, %{})},
               transaction
             ) do
        {:ok, Map.replace!(confirmed_transaction, :account, account)}
      end
    end)
  end
end
