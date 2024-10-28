defmodule ExLedger.Accounts.UpdateAccountStatus do
  @moduledoc """
  Updates the account's status.
  """
  alias ExLedger.Accounts.{Account, FetchAccount, UpdateAccount}
  alias ExLedger.Enums.AccountStatus
  alias __MODULE__

  @type params :: %{
          required(:status) => AccountStatus.t(),
          required(:account_id) => non_neg_integer()
        }

  @spec execute(UpdateAccountStatus.params()) ::
          {:ok, Account.t()} | {:error, :account_not_found | Ecto.Changeset.t()}
  def execute(params) do
    case FetchAccount.execute(params.account_id) do
      {:ok, account} -> UpdateAccount.execute(%{status: params.status}, account)
      error -> error
    end
  end
end
