defmodule ExLedger.Accounts.UpdateAccountProperties do
  @moduledoc """
  Updates the account's properties.
  """
  alias ExLedger.Accounts.{Account, FetchAccount, UpdateAccount}
  alias __MODULE__

  @type params :: %{
          required(:properties) => map(),
          required(:account_id) => non_neg_integer()
        }

  @spec execute(params :: UpdateAccountProperties.params()) ::
          {:ok, Account.t()} | {:error, :account_not_found | Ecto.Changeset.t()}
  def execute(params) do
    case FetchAccount.execute(params.account_id) do
      {:ok, account} -> UpdateAccount.execute(%{properties: params.properties}, account)
      error -> error
    end
  end
end
