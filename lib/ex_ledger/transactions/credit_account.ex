defmodule ExLedger.Transactions.CreditAccount do
  @moduledoc """
  Adds the transaction amount to the account's balance.
  """
  alias ExLedger.Accounts.{Account, LockAccount, UpdateAccount}
  alias ExLedger.Transactions.Transaction

  require Logger

  @spec execute(transaction :: Transaction.t()) :: {:ok, Account.t()} | {:error, :internal_error}
  def execute(%Transaction{amount: transaction_amount, account_id: account_id}) do
    case LockAccount.execute(account_id) do
      {:ok, account} ->
        Logger.info("[ExLedger] crediting #{transaction_amount} to Account (ID=#{account_id})")
        credit_account(transaction_amount, account)

      error ->
        error
    end
  end

  defp credit_account(transaction_amount, %Account{balance: account_balance} = account) do
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
