defmodule <%= inspect repo %>.Migrations.AddExLedger do
  use Ecto.Migration

  alias ExLedger.Accounts.{
    AccountStatus,
    AccountType,
    AccountCurrency
  }

  alias ExLedger.Transactions.{
    TransactionStatus,
    TransactionType
  }

  def change do
    AccountStatus.create_type()
    AccountType.create_type()
    AccountCurrency.create_type()

    create table(:accounts) do
      add(:balance, :decimal, precision: 28, scale: 12, null: false)
      add(:currency, AccountCurrency.type(), null: false)
      add(:type, AccountType.type(), null: false)
      add(:status, AccountStatus.type(), null: false)
      add(:properties, :map)

      timestamps(type: :utc_datetime)
    end

    create(index(:accounts, [:balance]))
    create(index(:accounts, [:currency]))
    create(index(:accounts, [:type]))
    create(index(:accounts, [:status]))
    create(index(:accounts, [:properties], using: :gin))

    create(
      constraint(:accounts, :balance_must_be_greater_than_or_equal_to_zero, check: "balance >= 0")
    )

    TransactionStatus.create_type()
    TransactionType.create_type()

    create table(:transactions) do
      add(:amount, :decimal, precision: 28, scale: 12, null: false)
      add(:type, TransactionType.type(), null: false)
      add(:status, TransactionStatus.type(), null: false)
      add(:properties, :map)
      add(:account_id, references(:accounts), null: false)

      timestamps(type: :utc_datetime)
    end

    create(index(:transactions, [:type]))
    create(index(:transactions, [:status]))
    create(index(:transactions, [:account_id]))
    create(index(:transactions, [:properties], using: :gin))
    create(constraint(:transactions, :amount_must_be_greater_than_zero, check: "amount > 0"))
  end
end
