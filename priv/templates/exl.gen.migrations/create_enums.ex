defmodule <%= inspect repo %>.Migrations.CreateEnums do
  use Ecto.Migration

  alias ExLedger.Enums.{
    AccountStatus,
    AccountType,
    Currency,
    TransactionStatus,
    TransactionType
  }

  def change do
    AccountStatus.create_type()
    AccountType.create_type()
    Currency.create_type()
    TransactionStatus.create_type()
    TransactionType.create_type()
  end
end
