defmodule ExLedger.Accounts.ExLedgerTest do
  use ExLedger.DataCase

  alias ExLedger.Accounts.Account
  alias ExLedger.AccountTypes.CryptoAccount
  alias ExLedger.Transactions.Transaction
  alias ExLedger.TransactionTypes.{CryptoDeposit, CryptoWithdrawal}

  @crypto_account_properties %{
    address: "0xb794f5ea0ba39494ce839613fffba74279579268",
    blockchain: "ETHEREUM"
  }
  @crypto_deposit_properties %{
    from_address: "0x1234556789",
    confirmations: 0
  }
  @crypto_withdrawal_properties %{
    to_address: "0x987654321",
    confirmations: 0
  }

  describe "create_account/1" do
    test "creates an account" do
      %{currency: currency, type: type} =
        params = %{
          currency: :ETH,
          type: :crypto_account,
          properties: @crypto_account_properties
        }

      properties = struct(CryptoAccount, @crypto_account_properties)

      assert {:ok, %Account{id: account_id}} = ExLedger.create_account(params)

      assert %Account{
               balance: account_balance,
               currency: ^currency,
               type: ^type,
               properties: ^properties,
               status: :enabled
             } =
               Repo.get(Account, account_id)

      assert Decimal.eq?(account_balance, Decimal.new(0))
    end

    test "creates an account without properties" do
      %{currency: currency, type: type} =
        params = %{
          currency: :ETH,
          type: :crypto_account,
          properties: %{}
        }

      assert {:ok, %Account{id: account_id}} = ExLedger.create_account(params)

      assert %Account{
               balance: account_balance,
               currency: ^currency,
               type: ^type,
               properties: nil,
               status: :enabled
             } =
               Repo.get(Account, account_id)

      assert Decimal.eq?(account_balance, Decimal.new(0))
    end

    test "fails if currency is nil" do
      params = %{
        currency: nil,
        type: :crypto_account,
        properties: @crypto_account_properties
      }

      assert {:error, changeset} = ExLedger.create_account(params)
      assert "can't be blank" in errors_on(changeset).currency
    end

    test "fails if currency is invalid" do
      params = %{
        currency: :invalid_currency,
        type: :crypto_account,
        properties: @crypto_account_properties
      }

      assert {:error, changeset} = ExLedger.create_account(params)
      assert "is invalid" in errors_on(changeset).currency
    end

    test "fails if type is nil" do
      params = %{
        currency: :ETH,
        type: nil,
        properties: @crypto_account_properties
      }

      assert {:error, changeset} = ExLedger.create_account(params)
      assert "can't be blank" in errors_on(changeset).type
    end

    test "fails if type is invalid" do
      params = %{
        currency: :ETH,
        type: :invalid_type,
        properties: @crypto_account_properties
      }

      assert {:error, changeset} = ExLedger.create_account(params)
      assert "is invalid" in errors_on(changeset).type
    end

    test "fails if properties are nil" do
      params = %{
        currency: :ETH,
        type: :crypto_account,
        properties: nil
      }

      assert {:error, changeset} = ExLedger.create_account(params)
      assert "can't be blank" in errors_on(changeset).properties
    end

    test "fails if property is nil" do
      params = %{
        currency: :ETH,
        type: :crypto_account,
        properties: Map.replace!(@crypto_account_properties, :address, nil)
      }

      assert {:error, changeset} = ExLedger.create_account(params)
      assert "can't be blank" in errors_on(changeset).properties_address
    end

    test "fails if property is invalid" do
      params = %{
        currency: :ETH,
        type: :crypto_account,
        properties: Map.replace!(@crypto_account_properties, :address, 123)
      }

      assert {:error, changeset} = ExLedger.create_account(params)
      assert "is invalid" in errors_on(changeset).properties_address
    end
  end

  describe "update_account_status/1" do
    setup do
      %{account_id: create_account!().id}
    end

    test "updates the account's status", %{account_id: account_id} do
      %{status: status} =
        params = %{
          status: :disabled,
          account_id: account_id
        }

      assert {:ok,
              %Account{
                id: ^account_id
              }} =
               ExLedger.update_account_status(params)

      assert %Account{status: ^status} = Repo.get(Account, account_id)
    end

    test "fails if the account does not exist" do
      params = %{status: :disabled, account_id: 99999}

      assert {:error, :account_not_found} = ExLedger.update_account_status(params)
    end

    test "fails if account_id is nil" do
      params = %{status: :disabled, account_id: nil}

      assert {:error, :account_not_found} = ExLedger.update_account_status(params)
    end

    test "fails if status is nil", %{account_id: account_id} do
      params = %{status: nil, account_id: account_id}

      assert {:error, changeset} = ExLedger.update_account_status(params)
      assert "can't be blank" in errors_on(changeset).status
    end

    test "fails if status is invalid", %{account_id: account_id} do
      params = %{status: :invalid_status, account_id: account_id}

      assert {:error, changeset} = ExLedger.update_account_status(params)
      assert "is invalid" in errors_on(changeset).status
    end
  end

  describe "update_account_properties/1" do
    setup do
      %{account_id: create_account!().id}
    end

    test "updates the account's properties", %{account_id: account_id} do
      %{properties: %{address: address}} =
        params = %{
          properties: %{address: "new address"},
          account_id: account_id
        }

      assert {:ok,
              %Account{
                id: ^account_id
              }} =
               ExLedger.update_account_properties(params)

      assert %Account{properties: %CryptoAccount{address: ^address}} =
               Repo.get(Account, account_id)
    end

    test "fails if the account does not exist" do
      params = %{properties: %{address: "new address"}, account_id: 99999}

      assert {:error, :account_not_found} = ExLedger.update_account_properties(params)
    end

    test "fails if account_id is nil" do
      params = %{properties: %{address: "new address"}, account_id: nil}

      assert {:error, :account_not_found} = ExLedger.update_account_properties(params)
    end

    test "fails if properties are nil", %{account_id: account_id} do
      params = %{properties: nil, account_id: account_id}

      assert {:error, changeset} = ExLedger.update_account_properties(params)
      assert "can't be blank" in errors_on(changeset).properties
    end

    test "fails if property is nil", %{account_id: account_id} do
      params = %{properties: %{address: nil}, account_id: account_id}

      assert {:error, changeset} = ExLedger.update_account_properties(params)
      assert "can't be blank" in errors_on(changeset).properties_address
    end

    test "fails if property is invalid", %{account_id: account_id} do
      params = %{properties: %{address: 123}, account_id: account_id}

      assert {:error, changeset} = ExLedger.update_account_properties(params)
      assert "is invalid" in errors_on(changeset).properties_address
    end
  end

  describe "create_deposit/1" do
    setup do
      %{account_id: create_account!().id}
    end

    test "creates a deposit transaction", %{
      account_id: account_id
    } do
      %{amount: amount, type: type, properties: properties} =
        params = %{
          amount: Decimal.new(10),
          type: :crypto_deposit,
          properties: @crypto_deposit_properties,
          account_id: account_id
        }

      assert {:ok,
              %Transaction{
                id: transaction_id
              }} =
               ExLedger.create_deposit(params)

      properties = struct(CryptoDeposit, properties)

      assert %Transaction{
               amount: transaction_amount,
               type: ^type,
               status: :created,
               properties: ^properties,
               account_id: ^account_id
             } =
               Repo.get(Transaction, transaction_id)

      assert Decimal.eq?(amount, transaction_amount)
    end

    test "creates a deposit transaction without properties", %{
      account_id: account_id
    } do
      %{amount: amount, type: type} =
        params = %{
          amount: Decimal.new(10),
          type: :crypto_deposit,
          properties: %{},
          account_id: account_id
        }

      assert {:ok,
              %Transaction{
                id: transaction_id
              }} =
               ExLedger.create_deposit(params)

      assert %Transaction{
               amount: transaction_amount,
               type: ^type,
               status: :created,
               properties: nil,
               account_id: ^account_id
             } =
               Repo.get(Transaction, transaction_id)

      assert Decimal.eq?(amount, transaction_amount)
    end

    test "fails if the account does not exist" do
      params = %{
        amount: Decimal.new(10),
        type: :crypto_deposit,
        properties: @crypto_deposit_properties,
        account_id: 99999
      }

      assert {:error, changeset} = ExLedger.create_deposit(params)
      assert "does not exist" in errors_on(changeset).account_id
    end

    test "fails if account_id is nil" do
      params = %{
        amount: Decimal.new(10),
        type: :crypto_deposit,
        properties: @crypto_deposit_properties,
        account_id: nil
      }

      assert {:error, changeset} = ExLedger.create_deposit(params)
      assert "can't be blank" in errors_on(changeset).account_id
    end

    test "fails if amount is nil", %{account_id: account_id} do
      params = %{
        amount: nil,
        type: :crypto_deposit,
        properties: @crypto_deposit_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_deposit(params)
      assert "can't be blank" in errors_on(changeset).amount
    end

    test "fails if amount is invalid", %{account_id: account_id} do
      params = %{
        amount: "invalid_amount",
        type: :crypto_deposit,
        properties: @crypto_deposit_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_deposit(params)
      assert "is invalid" in errors_on(changeset).amount
    end

    test "fails if amount is negative", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(-10),
        type: :crypto_deposit,
        properties: @crypto_deposit_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_deposit(params)
      assert "must be greater than zero" in errors_on(changeset).amount
    end

    test "fails if amount is zero", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(0),
        type: :crypto_deposit,
        properties: @crypto_deposit_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_deposit(params)
      assert "must be greater than zero" in errors_on(changeset).amount
    end

    test "fails if type is nil", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(10),
        type: nil,
        properties: @crypto_deposit_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_deposit(params)
      assert "can't be blank" in errors_on(changeset).type
    end

    test "fails if type is invalid", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(10),
        type: :invalid_type,
        properties: @crypto_deposit_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_deposit(params)
      assert "is invalid" in errors_on(changeset).type
    end

    test "fails if properties are nil", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(10),
        type: :crypto_deposit,
        properties: nil,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_deposit(params)
      assert "can't be blank" in errors_on(changeset).properties
    end

    test "fails if property is nil", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(10),
        type: :crypto_deposit,
        properties: Map.replace!(@crypto_deposit_properties, :from_address, nil),
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_deposit(params)
      assert "can't be blank" in errors_on(changeset).properties_from_address
    end

    test "fails if property is invalid", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(10),
        type: :crypto_deposit,
        properties: Map.replace!(@crypto_deposit_properties, :from_address, 123),
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_deposit(params)
      assert "is invalid" in errors_on(changeset).properties_from_address
    end
  end

  describe "confirm_deposit/1" do
    setup do
      transaction =
        create_account!()
        |> create_deposit!()

      %{transaction_id: transaction.id}
    end

    test "confirms the deposit transaction", %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      assert {:ok,
              %Transaction{
                id: ^transaction_id,
                amount: transaction_amount,
                account_id: account_id
              }} =
               ExLedger.confirm_deposit(params)

      assert %Transaction{status: :confirmed} = Repo.get(Transaction, transaction_id)
      assert %Account{balance: account_balance} = Repo.get(Account, account_id)
      assert Decimal.eq?(account_balance, transaction_amount)
    end

    test "confirms the deposit transaction and updates it's properties", %{
      transaction_id: transaction_id
    } do
      %{properties: %{confirmations: confirmations}} =
        params = %{transaction_id: transaction_id, properties: %{confirmations: 10}}

      assert {:ok,
              %Transaction{
                id: ^transaction_id,
                amount: transaction_amount,
                account_id: account_id
              }} =
               ExLedger.confirm_deposit(params)

      assert %Transaction{
               status: :confirmed,
               properties: %CryptoDeposit{confirmations: ^confirmations}
             } = Repo.get(Transaction, transaction_id)

      assert %Account{balance: account_balance} = Repo.get(Account, account_id)
      assert Decimal.eq?(account_balance, transaction_amount)
    end

    test "fails if transaction_id is nil", %{transaction_id: _transaction_id} do
      params = %{transaction_id: nil}

      assert {:error, :transaction_not_found} = ExLedger.confirm_deposit(params)
    end

    test "fails if transaction does not exist", %{transaction_id: _transaction_id} do
      params = %{transaction_id: 99999}

      assert {:error, :transaction_not_found} = ExLedger.confirm_deposit(params)
    end

    test "fails if the transaction has already been confirmed", %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      {:ok, _transaction} = ExLedger.confirm_deposit(params)
      assert {:error, :transaction_already_processed} = ExLedger.confirm_deposit(params)
    end

    test "fails if transaction has already failed", %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      {:ok, _transaction} = ExLedger.fail_deposit(params)
      assert {:error, :transaction_already_processed} = ExLedger.confirm_deposit(params)
    end
  end

  describe "fail_deposit/1" do
    setup do
      transaction =
        create_account!()
        |> create_deposit!()

      %{transaction_id: transaction.id}
    end

    test "marks the transaction as failed", %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      assert {:ok, %Transaction{id: ^transaction_id}} = ExLedger.fail_deposit(params)

      assert %Transaction{status: :failed} = Repo.get(Transaction, transaction_id)
    end

    test "marks the transaction as failed and updates it's properties", %{
      transaction_id: transaction_id
    } do
      %{properties: %{confirmations: confirmations}} =
        params = %{transaction_id: transaction_id, properties: %{confirmations: 10}}

      assert {:ok, %Transaction{id: ^transaction_id}} = ExLedger.fail_deposit(params)

      assert %Transaction{
               status: :failed,
               properties: %CryptoDeposit{confirmations: ^confirmations}
             } = Repo.get(Transaction, transaction_id)
    end

    test "fails if the transaction has already been confirmed", %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      {:ok, _transaction} = ExLedger.confirm_deposit(params)
      assert {:error, :transaction_already_processed} = ExLedger.fail_deposit(params)
    end

    test "fails if the transaction has already failed", %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      {:ok, _transaction} = ExLedger.fail_deposit(params)
      assert {:error, :transaction_already_processed} = ExLedger.fail_deposit(params)
    end
  end

  describe "create_withdrawal/1" do
    setup do
      account = create_account!()

      account
      |> create_deposit!()
      |> confirm_deposit!()

      %{account_id: account.id}
    end

    test "creates a withdrawal transaction", %{
      account_id: account_id
    } do
      %{amount: amount, type: type, properties: properties} =
        params = %{
          amount: Decimal.new(10),
          type: :crypto_withdrawal,
          properties: @crypto_withdrawal_properties,
          account_id: account_id
        }

      assert {:ok,
              %Transaction{
                id: transaction_id
              }} =
               ExLedger.create_withdrawal(params)

      properties = struct(CryptoWithdrawal, properties)

      assert %Transaction{
               amount: transaction_amount,
               type: ^type,
               status: :created,
               properties: ^properties,
               account_id: ^account_id
             } =
               Repo.get(Transaction, transaction_id)

      assert Decimal.eq?(amount, transaction_amount)

      assert %Account{balance: account_balance} = Repo.get(Account, account_id)
      assert Decimal.eq?(account_balance, 0)
    end

    test "creates a withdrawal transaction without properties", %{
      account_id: account_id
    } do
      %{amount: amount, type: type} =
        params = %{
          amount: Decimal.new(10),
          type: :crypto_withdrawal,
          properties: %{},
          account_id: account_id
        }

      assert {:ok,
              %Transaction{
                id: transaction_id
              }} =
               ExLedger.create_withdrawal(params)

      assert %Transaction{
               amount: transaction_amount,
               type: ^type,
               status: :created,
               properties: nil,
               account_id: ^account_id
             } =
               Repo.get(Transaction, transaction_id)

      assert Decimal.eq?(amount, transaction_amount)

      assert %Account{balance: account_balance} = Repo.get(Account, account_id)
      assert Decimal.eq?(account_balance, 0)
    end

    test "fails if the account does not have enough balance", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(10),
        type: :crypto_withdrawal,
        properties: @crypto_withdrawal_properties,
        account_id: account_id
      }

      assert {:ok, _transaction} = ExLedger.create_withdrawal(params)
      assert {:error, :insufficient_account_balance} = ExLedger.create_withdrawal(params)
    end

    test "fails if the account does not exist" do
      params = %{
        amount: Decimal.new(10),
        type: :crypto_withdrawal,
        properties: @crypto_withdrawal_properties,
        account_id: 99999
      }

      assert {:error, changeset} = ExLedger.create_withdrawal(params)
      assert "does not exist" in errors_on(changeset).account_id
    end

    test "fails if account_id is nil" do
      params = %{
        amount: Decimal.new(10),
        type: :crypto_withdrawal,
        properties: @crypto_withdrawal_properties,
        account_id: nil
      }

      assert {:error, changeset} = ExLedger.create_withdrawal(params)
      assert "can't be blank" in errors_on(changeset).account_id
    end

    test "fails if amount is nil", %{account_id: account_id} do
      params = %{
        amount: nil,
        type: :crypto_withdrawal,
        properties: @crypto_withdrawal_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_withdrawal(params)
      assert "can't be blank" in errors_on(changeset).amount
    end

    test "fails if amount is invalid", %{account_id: account_id} do
      params = %{
        amount: "invalid_amount",
        type: :crypto_withdrawal,
        properties: @crypto_withdrawal_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_withdrawal(params)
      assert "is invalid" in errors_on(changeset).amount
    end

    test "fails if amount is negative", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(-10),
        type: :crypto_withdrawal,
        properties: @crypto_withdrawal_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_withdrawal(params)
      assert "must be greater than zero" in errors_on(changeset).amount
    end

    test "fails if amount is zero", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(0),
        type: :crypto_withdrawal,
        properties: @crypto_withdrawal_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_withdrawal(params)
      assert "must be greater than zero" in errors_on(changeset).amount
    end

    test "fails if type is nil", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(10),
        type: nil,
        properties: @crypto_withdrawal_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_withdrawal(params)
      assert "can't be blank" in errors_on(changeset).type
    end

    test "fails if type is invalid", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(10),
        type: :invalid_type,
        properties: @crypto_withdrawal_properties,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_withdrawal(params)
      assert "is invalid" in errors_on(changeset).type
    end

    test "fails if properties are nil", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(10),
        type: :crypto_withdrawal,
        properties: nil,
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_withdrawal(params)
      assert "can't be blank" in errors_on(changeset).properties
    end

    test "fails if property is nil", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(10),
        type: :crypto_withdrawal,
        properties: Map.replace!(@crypto_withdrawal_properties, :to_address, nil),
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_withdrawal(params)
      assert "can't be blank" in errors_on(changeset).properties_to_address
    end

    test "fails if property is invalid", %{account_id: account_id} do
      params = %{
        amount: Decimal.new(10),
        type: :crypto_withdrawal,
        properties: Map.replace!(@crypto_withdrawal_properties, :to_address, 123),
        account_id: account_id
      }

      assert {:error, changeset} = ExLedger.create_withdrawal(params)
      assert "is invalid" in errors_on(changeset).properties_to_address
    end
  end

  describe "confirm_withdrawal/1" do
    setup do
      account = create_account!()

      account
      |> create_deposit!()
      |> confirm_deposit!()

      %{transaction_id: create_withdrawal!(account).id}
    end

    test "confirms the withdrawal transaction
    ",
         %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      assert {:ok, %Transaction{id: ^transaction_id}} = ExLedger.confirm_withdrawal(params)
      assert %Transaction{status: :confirmed} = Repo.get(Transaction, transaction_id)
    end

    test "confirms the withdrawal transaction and updates it's properties", %{
      transaction_id: transaction_id
    } do
      %{properties: %{confirmations: confirmations}} =
        params = %{transaction_id: transaction_id, properties: %{confirmations: 10}}

      assert {:ok, %Transaction{id: ^transaction_id}} = ExLedger.confirm_withdrawal(params)

      assert %Transaction{
               status: :confirmed,
               properties: %CryptoWithdrawal{confirmations: ^confirmations}
             } = Repo.get(Transaction, transaction_id)
    end

    test "fails if the transaction does not exist", %{transaction_id: _transaction_id} do
      params = %{transaction_id: 99999}

      assert {:error, :transaction_not_found} = ExLedger.confirm_withdrawal(params)
    end

    test "fails if transaction_id is nil", %{transaction_id: _transaction_id} do
      params = %{transaction_id: nil}

      assert {:error, :transaction_not_found} = ExLedger.confirm_withdrawal(params)
    end

    test "fails if the transaction has already been confirmed", %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      {:ok, _transaction} = ExLedger.confirm_withdrawal(params)
      assert {:error, :transaction_already_processed} = ExLedger.confirm_withdrawal(params)
    end

    test "fails if transaction has already failed", %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      {:ok, _transaction} = ExLedger.fail_withdrawal(params)
      assert {:error, :transaction_already_processed} = ExLedger.confirm_withdrawal(params)
    end
  end

  describe "fail_withdrawal/1" do
    setup do
      account = create_account!()

      account
      |> create_deposit!()
      |> confirm_deposit!()

      transaction = create_withdrawal!(account)

      %{transaction_id: transaction.id}
    end

    test "marks the transaction as failed", %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      assert {:ok, %Transaction{id: ^transaction_id, account_id: account_id}} =
               ExLedger.fail_withdrawal(params)

      assert %Transaction{status: :failed} = Repo.get(Transaction, transaction_id)

      account = Repo.get(Account, account_id)
      assert Decimal.eq?(account.balance, Decimal.new(10))
    end

    test "marks the transaction as failed and updates it's properties", %{
      transaction_id: transaction_id
    } do
      %{properties: %{confirmations: confirmations}} =
        params = %{transaction_id: transaction_id, properties: %{confirmations: 10}}

      assert {:ok, %Transaction{id: ^transaction_id, account_id: account_id}} =
               ExLedger.fail_withdrawal(params)

      assert %Transaction{
               status: :failed,
               properties: %CryptoWithdrawal{confirmations: ^confirmations}
             } = Repo.get(Transaction, transaction_id)

      account = Repo.get(Account, account_id)
      assert Decimal.eq?(account.balance, Decimal.new(10))
    end

    test "fails if the transaction has already been confirmed", %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      {:ok, _transaction} = ExLedger.confirm_withdrawal(params)
      assert {:error, :transaction_already_processed} = ExLedger.fail_withdrawal(params)
    end

    test "fails if the transaction has already failed", %{transaction_id: transaction_id} do
      params = %{transaction_id: transaction_id}

      {:ok, _transaction} = ExLedger.fail_withdrawal(params)
      assert {:error, :transaction_already_processed} = ExLedger.fail_withdrawal(params)
    end
  end

  describe "update_transaction_properties/1" do
    setup do
      transaction =
        create_account!()
        |> create_deposit!()

      %{transaction_id: transaction.id}
    end

    test "updates the transaction's properties", %{transaction_id: transaction_id} do
      %{properties: %{confirmations: confirmations}} =
        params = %{
          properties: %{confirmations: 5},
          transaction_id: transaction_id
        }

      assert {:ok,
              %Transaction{
                id: ^transaction_id
              }} =
               ExLedger.update_transaction_properties(params)

      assert %Transaction{properties: %CryptoDeposit{confirmations: ^confirmations}} =
               Repo.get(Transaction, transaction_id)
    end

    test "fails if the transaction does not exist" do
      params = %{properties: %{confirmations: 5}, transaction_id: 99999}

      assert {:error, :transaction_not_found} = ExLedger.update_transaction_properties(params)
    end

    test "fails if transaction_id is nil" do
      params = %{properties: %{confirmations: 5}, transaction_id: nil}

      assert {:error, :transaction_not_found} = ExLedger.update_transaction_properties(params)
    end

    test "fails if properties are nil", %{transaction_id: transaction_id} do
      params = %{properties: nil, transaction_id: transaction_id}

      assert {:error, changeset} = ExLedger.update_transaction_properties(params)
      assert "can't be blank" in errors_on(changeset).properties
    end

    test "fails if property is nil", %{transaction_id: transaction_id} do
      params = %{properties: %{confirmations: nil}, transaction_id: transaction_id}

      assert {:error, changeset} = ExLedger.update_transaction_properties(params)
      assert "can't be blank" in errors_on(changeset).properties_confirmations
    end

    test "fails if property is invalid", %{transaction_id: transaction_id} do
      params = %{properties: %{confirmations: "abcd"}, transaction_id: transaction_id}

      assert {:error, changeset} = ExLedger.update_transaction_properties(params)
      assert "is invalid" in errors_on(changeset).properties_confirmations
    end
  end

  defp create_account! do
    {:ok, account} =
      ExLedger.create_account(%{
        currency: :ETH,
        type: :crypto_account,
        properties: @crypto_account_properties
      })

    account
  end

  defp create_deposit!(account) do
    {:ok, transaction} =
      ExLedger.create_deposit(%{
        amount: Decimal.new(10),
        type: :crypto_deposit,
        properties: @crypto_deposit_properties,
        account_id: account.id
      })

    transaction
  end

  defp confirm_deposit!(transaction) do
    {:ok, transaction} =
      ExLedger.confirm_deposit(%{
        transaction_id: transaction.id
      })

    transaction
  end

  defp create_withdrawal!(account) do
    {:ok, transaction} =
      ExLedger.create_withdrawal(%{
        amount: Decimal.new(10),
        type: :crypto_withdrawal,
        properties: @crypto_withdrawal_properties,
        account_id: account.id
      })

    transaction
  end
end
