defmodule ExLedger.Transactions.CreateWithdrawal do
  @moduledoc """
  Creates a withdrawal transaction and debits the account.
  """
  alias ExLedger.Accounts.LockAccount
  alias ExLedger.Repo
  alias ExLedger.Transactions.{CreateTransaction, DebitAccount, Transaction, TransactionType}
  alias __MODULE__

  @type params :: %{
          required(:amount) => Decimal.t(),
          required(:type) => TransactionType.t(),
          required(:properties) => map(),
          required(:account_id) => non_neg_integer()
        }

  @spec execute(params :: CreateWithdrawal.params()) ::
          {:ok, Transaction.t()}
          | {:error,
             :insufficient_account_balance
             | :internal_error
             | Ecto.Changeset.t()}
  def execute(params) do
    Repo.transaction(fn ->
      with {:ok, account} <- LockAccount.execute(params.account_id),
           {:ok, transaction} <- CreateTransaction.execute(params),
           {:ok, account} <- DebitAccount.execute(transaction, account) do
        {:ok, Map.replace!(transaction, :account, account)}
      end
    end)
  end
end
