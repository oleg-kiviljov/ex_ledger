defmodule ExLedger.Accounts.LockAccount do
  @moduledoc """
  Locks the account for update.
  """
  alias ExLedger.Accounts.{Account, AccountQuery}
  alias ExLedger.Repo

  @spec execute(account_id :: non_neg_integer()) ::
          {:ok, Account.t()} | {:error, :account_not_found}
  def execute(account_id) do
    account_id
    |> AccountQuery.with_lock()
    |> Repo.one()
    |> case do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end
end
