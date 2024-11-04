defmodule ExLedger.Accounts.CreateAccount do
  @moduledoc """
  Creates an account.
  """
  alias ExLedger.Accounts.{Account, AccountCurrency, AccountType}
  alias ExLedger.Repo
  alias __MODULE__

  @type params :: %{
          required(:currency) => AccountCurrency.t(),
          required(:type) => AccountType.t(),
          optional(:properties) => map()
        }

  @spec execute(params :: CreateAccount.params()) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def execute(params) do
    params
    |> Account.create_changeset()
    |> Repo.insert()
  end
end
