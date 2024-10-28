defmodule ExLedger.Accounts.CreateAccount do
  @moduledoc """
  Creates an account.
  """
  alias ExLedger.Accounts.Account
  alias ExLedger.Enums.{AccountType, Currency}
  alias ExLedger.Repo
  alias __MODULE__

  @type params :: %{
          required(:currency) => Currency.t(),
          required(:type) => AccountType.t(),
          required(:properties) => map()
        }

  @spec execute(CreateAccount.params()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def execute(params) do
    params
    |> Account.create_changeset()
    |> Repo.insert()
  end
end
