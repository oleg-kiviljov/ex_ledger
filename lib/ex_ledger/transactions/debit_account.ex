defmodule ExLedger.Transactions.DebitAccount do
  @moduledoc """
  Subtracts the transaction amount from the account's balance.
  """
  alias ExLedger.Accounts.{Account, UpdateAccount}
  alias ExLedger.Transactions.Transaction

  @spec execute(transaction :: Transaction.t(), account :: Account.t()) ::
          {:ok, Account.t()} | {:error, :insufficient_account_balance | :internal_error}
  def execute(transaction, account) do
    debit_account(transaction, account)
  end

  defp debit_account(
         %Transaction{amount: transaction_amount},
         %Account{balance: account_balance} = account
       ) do
    account_balance
    |> Decimal.sub(transaction_amount)
    |> update_account_balance(account)
  end

  defp update_account_balance(balance, account) do
    case UpdateAccount.execute(%{balance: balance}, account) do
      {:error, changeset} ->
        handle_error(changeset)

      result ->
        result
    end
  end

  defp handle_error(%Ecto.Changeset{errors: errors}) do
    case Keyword.get(errors, :balance) do
      {"must be greater than or equal to zero", _opts} ->
        {:error, :insufficient_account_balance}

      _ ->
        {:error, :internal_error}
    end
  end
end
