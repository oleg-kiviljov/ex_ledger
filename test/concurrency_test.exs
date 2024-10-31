defmodule ExLedger.ConcurrencyTest do
  use ExLedger.DataCase
  @moduletag :no_sandbox

  describe "confirm_deposit/1" do
    setup do
      %{account: create_account!()}
    end

    test "ensures database locks are handled correctly for single deposit", %{account: account} do
      %Transaction{id: transaction_id} =
        deposit = create_deposit!(account, Decimal.new(:rand.uniform(100)))

      results =
        Enum.map(1..10, fn _ ->
          Task.async(fn ->
            unboxed_run(fn ->
              ExLedger.confirm_deposit(%{transaction_id: deposit.id})
            end)
          end)
        end)
        |> Task.await_many()

      assert {:ok, %Transaction{id: ^transaction_id, status: :confirmed}} =
               Keyword.fetch(results, :ok)

      results
      |> Keyword.drop([:ok])
      |> Enum.all?(fn {:error, reason} ->
        assert reason == :transaction_already_processed
      end)

      assert %Account{balance: account_balance} = Repo.get(Account, account.id)
      assert Decimal.eq?(account_balance, deposit.amount)
    end

    test "ensures database locks are handled correctly for multiple deposits", %{account: account} do
      deposits =
        Enum.map(1..10, fn _ ->
          create_deposit!(account, Decimal.new(:rand.uniform(100)))
        end)

      deposits
      |> Enum.shuffle()
      |> Enum.map(fn deposit ->
        Task.async(fn ->
          unboxed_run(fn ->
            ExLedger.confirm_deposit(%{transaction_id: deposit.id})
          end)
        end)
      end)
      |> Task.await_many()

      total_deposited_amount =
        Enum.reduce(deposits, Decimal.new(0), fn deposit, acc ->
          Decimal.add(acc, deposit.amount)
        end)

      assert %Account{balance: account_balance} = Repo.get(Account, account.id)
      assert Decimal.eq?(account_balance, total_deposited_amount)
    end
  end

  describe "fail_deposit/1" do
    test "ensures database locks are handled correctly for single deposit" do
      account = create_account!()

      %Transaction{id: transaction_id} =
        deposit = create_deposit!(account, Decimal.new(:rand.uniform(100)))

      results =
        Enum.map(1..10, fn _ ->
          Task.async(fn ->
            unboxed_run(fn ->
              ExLedger.fail_deposit(%{transaction_id: deposit.id})
            end)
          end)
        end)
        |> Task.await_many()

      assert {:ok, %Transaction{id: ^transaction_id, status: :failed}} =
               Keyword.fetch(results, :ok)

      results
      |> Keyword.drop([:ok])
      |> Enum.all?(fn {:error, reason} ->
        assert reason == :transaction_already_processed
      end)
    end
  end

  describe "create_withdrawal/1" do
    setup do
      account = create_account!()
      initial_account_balance = Decimal.new(10_000)

      account
      |> create_deposit!(initial_account_balance)
      |> confirm_deposit!()

      %{account: account, initial_account_balance: initial_account_balance}
    end

    test "ensures database locks are handled correctly for multiple withdrawals", %{
      account: account,
      initial_account_balance: initial_account_balance
    } do
      withdrawals =
        Enum.map(1..10, fn _ ->
          Task.async(fn ->
            unboxed_run(fn ->
              ExLedger.create_withdrawal(%{
                amount: :rand.uniform(100),
                type: :crypto_withdrawal,
                properties: crypto_withdrawal_properties(),
                account_id: account.id
              })
            end)
          end)
        end)
        |> Task.await_many()
        |> Enum.map(&elem(&1, 1))

      total_withdrawn_amount =
        Enum.reduce(withdrawals, Decimal.new(0), fn withdrawal, acc ->
          Decimal.add(acc, withdrawal.amount)
        end)

      assert %Account{balance: account_balance} = Repo.get(Account, account.id)
      expected_account_balance = Decimal.sub(initial_account_balance, total_withdrawn_amount)

      assert Decimal.eq?(account_balance, expected_account_balance)
    end
  end

  describe "confirm_withdrawal/1" do
    setup do
      account = create_account!()
      initial_account_balance = Decimal.new(10_000)

      account
      |> create_deposit!(initial_account_balance)
      |> confirm_deposit!()

      %{account: account}
    end

    test "ensures database locks are handled correctly for single withdrawal", %{account: account} do
      %Transaction{id: transaction_id} =
        withdrawal = create_withdrawal!(account, Decimal.new(:rand.uniform(100)))

      results =
        Enum.map(1..10, fn _ ->
          Task.async(fn ->
            unboxed_run(fn ->
              ExLedger.confirm_withdrawal(%{transaction_id: withdrawal.id})
            end)
          end)
        end)
        |> Task.await_many()

      assert {:ok, %Transaction{id: ^transaction_id, status: :confirmed}} =
               Keyword.fetch(results, :ok)

      results
      |> Keyword.drop([:ok])
      |> Enum.all?(fn {:error, reason} ->
        assert reason == :transaction_already_processed
      end)
    end
  end

  describe "fail_withdrawal/1" do
    setup do
      account = create_account!()
      initial_account_balance = Decimal.new(10_000)

      account
      |> create_deposit!(initial_account_balance)
      |> confirm_deposit!()

      %{account: account, initial_account_balance: initial_account_balance}
    end

    test "ensures database locks are handled correctly for single withdrawal", %{
      account: account,
      initial_account_balance: initial_account_balance
    } do
      %Transaction{id: transaction_id} =
        withdrawal = create_withdrawal!(account, Decimal.new(:rand.uniform(100)))

      results =
        Enum.map(1..10, fn _ ->
          Task.async(fn ->
            unboxed_run(fn ->
              ExLedger.fail_withdrawal(%{transaction_id: withdrawal.id})
            end)
          end)
        end)
        |> Task.await_many()

      assert {:ok, %Transaction{id: ^transaction_id, status: :failed}} =
               Keyword.fetch(results, :ok)

      results
      |> Keyword.drop([:ok])
      |> Enum.all?(fn {:error, reason} ->
        assert reason == :transaction_already_processed
      end)

      assert %Account{balance: account_balance} = Repo.get(Account, account.id)
      assert Decimal.eq?(account_balance, initial_account_balance)
    end

    test "ensures database locks are handled correctly for multiple withdrawals", %{
      account: account,
      initial_account_balance: initial_account_balance
    } do
      withdrawals =
        Enum.map(1..10, fn _ ->
          create_withdrawal!(account, Decimal.new(:rand.uniform(100)))
        end)

      withdrawals
      |> Enum.shuffle()
      |> Enum.map(fn withdrawal ->
        Task.async(fn ->
          unboxed_run(fn ->
            ExLedger.fail_withdrawal(%{
              transaction_id: withdrawal.id
            })
          end)
        end)
      end)
      |> Task.await_many()

      assert %Account{balance: account_balance} = Repo.get(Account, account.id)
      assert Decimal.eq?(account_balance, initial_account_balance)
    end
  end
end
