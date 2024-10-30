defmodule ExLedger.Transactions.CreditAccount do
  @moduledoc """
  Adds the transaction amount to the account's balance.
  """
  alias ExLedger.Accounts.{Account, UpdateAccount}
  alias ExLedger.Transactions.Transaction

  @spec execute(transaction :: Transaction.t(), account :: Account.t()) ::
          {:ok, Account.t()} | {:error, :internal_error}
  def execute(transaction, account) do
    credit_account(transaction, account)
  end

  defp credit_account(
         %Transaction{amount: transaction_amount},
         %Account{balance: account_balance} = account
       ) do
    account_balance
    |> Decimal.add(transaction_amount)
    |> update_account_balance(account)
    |> handle_result()
  end

  defp update_account_balance(balance, account),
    do: UpdateAccount.execute(%{balance: balance}, account)

  defp handle_result({:error, _reason}), do: {:error, :internal_error}
  defp handle_result(result), do: result
end
