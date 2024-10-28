defmodule ExLedger.Accounts.FetchAccount do
  @moduledoc """
  Fetches the account from the database if it exists.
  """
  alias ExLedger.Accounts.{Account, AccountQuery}
  alias ExLedger.Repo

  @spec execute(account_id :: non_neg_integer()) ::
          {:ok, Account.t()} | {:error, :account_not_found}

  def execute(nil), do: {:error, :account_not_found}

  def execute(account_id) do
    account_id
    |> AccountQuery.get()
    |> Repo.one()
    |> case do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end
end
