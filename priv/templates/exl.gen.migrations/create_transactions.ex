defmodule <%= inspect repo %>.Migrations.CreateTransactions do
  use Ecto.Migration

  alias ExLedger.Enums.{TransactionStatus, TransactionType}

  def change do
    create table(:transactions) do
      add(:amount, :decimal, precision: 28, scale: 12, null: false)
      add(:type, TransactionType.type(), null: false)
      add(:status, TransactionStatus.type(), null: false)
      add(:properties, :map)
      add(:account_id, references(:accounts), null: false)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:type])
    create index(:transactions, [:status])
    create index(:transactions, [:account_id])
    create index(:transactions, [:properties], using: :gin)
    create constraint(:transactions, :amount_must_be_greater_than_zero, check: "amount > 0")
  end
end
