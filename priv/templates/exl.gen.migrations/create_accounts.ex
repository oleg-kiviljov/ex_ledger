defmodule <%= inspect repo %>.Migrations.CreateAccounts do
  use Ecto.Migration

  alias ExLedger.Enums.{AccountStatus, AccountType, Currency}

  def change do
    create table(:accounts) do
      add(:balance, :decimal, precision: 28, scale: 12, null: false)
      add(:currency, Currency.type(), null: false)
      add(:type, AccountType.type(), null: false)
      add(:status, AccountStatus.type(), null: false)
      add(:properties, :map)

      timestamps(type: :utc_datetime)
    end

    create index(:accounts, [:balance])
    create index(:accounts, [:currency])
    create index(:accounts, [:type])
    create index(:accounts, [:status])
    create index(:accounts, [:properties], using: :gin)

    create constraint(:accounts, :balance_must_be_greater_than_or_equal_to_zero,
             check: "balance >= 0"
           )
  end
end
