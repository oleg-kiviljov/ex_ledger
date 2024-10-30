defmodule ExLedger.ConcurrencyTest do
  use ExLedger.DataCase
  @moduletag :no_sandbox

  describe "confirm_deposit/1" do
    test "ensures database locks are handled correctly" do
      account = create_account!()

      deposits =
        Enum.map(1..10, fn _ ->
          create_deposit!(account, Decimal.new(:rand.uniform(100)))
        end)

      total_deposited_amount =
        Enum.reduce(deposits, Decimal.new(0), fn deposit, acc ->
          Decimal.add(acc, deposit.amount)
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

      assert %Account{balance: account_balance} = Repo.get(Account, account.id)
      assert Decimal.eq?(account_balance, total_deposited_amount)
    end
  end

  describe "create_withdrawal/1" do
    test "ensures database locks are handled correctly" do
      starting_account_balance = Decimal.new(10_000)
      account = create_account!()

      account
      |> create_deposit!(starting_account_balance)
      |> confirm_deposit!()

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
      expected_account_balance = Decimal.sub(starting_account_balance, total_withdrawn_amount)

      assert Decimal.eq?(account_balance, expected_account_balance)
    end
  end
end
