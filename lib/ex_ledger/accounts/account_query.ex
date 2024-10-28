defmodule ExLedger.Accounts.AccountQuery do
  @moduledoc """
  Account queries.
  """
  alias ExLedger.Accounts.Account

  import Ecto.Query

  def get(query \\ base(), account_id) do
    where(query, [t], t.id == ^account_id)
  end

  def with_lock(query \\ base(), account_id) do
    query
    |> get(account_id)
    |> lock("FOR UPDATE")
  end

  defp base, do: Account
end
