defmodule ExLedger.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ExLedger.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias ExLedger.Accounts.Account
  alias ExLedger.TestRepo, as: Repo
  alias ExLedger.Transactions.Transaction

  using do
    quote do
      alias ExLedger.Accounts.Account
      alias ExLedger.AccountTypes.CryptoAccount
      alias ExLedger.TestRepo, as: Repo
      alias ExLedger.Transactions.Transaction
      alias ExLedger.TransactionTypes.{CryptoDeposit, CryptoWithdrawal}

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import ExLedger.DataCase
    end
  end

  setup tags do
    ExLedger.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(%{no_sandbox: true}) do
    pid = Sandbox.start_owner!(Repo, sandbox: false)

    on_exit(fn ->
      :ok = Sandbox.checkout(Repo, sandbox: false)
      Repo.delete_all(Transaction)
      Repo.delete_all(Account)
      Sandbox.stop_owner(pid)
    end)
  end

  def setup_sandbox(tags) do
    pid = Sandbox.start_owner!(Repo, shared: not tags[:async])
    on_exit(fn -> Sandbox.stop_owner(pid) end)
  end

  @doc """
  Automatically checks-out and checks-in connection for the function
  """
  def unboxed_run(fun) do
    Sandbox.unboxed_run(Repo, fun)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def crypto_account_properties do
    %{
      address: "0xb794f5ea0ba39494ce839613fffba74279579268",
      blockchain: "ETHEREUM"
    }
  end

  def crypto_deposit_properties do
    %{
      from_address: "0x1234556789",
      confirmations: 0
    }
  end

  def crypto_withdrawal_properties do
    %{
      to_address: "0x987654321",
      confirmations: 0
    }
  end

  def create_account! do
    {:ok, account} =
      ExLedger.create_account(%{
        currency: :ETH,
        type: :crypto_account,
        properties: crypto_account_properties()
      })

    account
  end

  def create_deposit!(account, amount \\ Decimal.new(10)) do
    {:ok, transaction} =
      ExLedger.create_deposit(%{
        amount: amount,
        type: :crypto_deposit,
        properties: crypto_deposit_properties(),
        account_id: account.id
      })

    transaction
  end

  def confirm_deposit!(transaction) do
    {:ok, transaction} =
      ExLedger.confirm_deposit(%{
        transaction_id: transaction.id
      })

    transaction
  end

  def create_withdrawal!(account, amount \\ Decimal.new(10)) do
    {:ok, transaction} =
      ExLedger.create_withdrawal(%{
        amount: amount,
        type: :crypto_withdrawal,
        properties: crypto_withdrawal_properties(),
        account_id: account.id
      })

    transaction
  end
end
