defmodule ExLedger.Accounts.UpdateAccount do
  @moduledoc """
  Updates the account.
  """
  alias ExLedger.Accounts.Account
  alias ExLedger.Repo

  @spec execute(params :: map(), account :: Account.t()) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def execute(params, account) do
    account
    |> Account.update_changeset(params)
    |> Repo.update()
  end
end
