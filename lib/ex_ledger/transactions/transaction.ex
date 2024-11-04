defmodule ExLedger.Transactions.Transaction do
  @moduledoc """
  Transaction schema.
  """
  use Ecto.Schema

  alias ExLedger.Accounts.Account
  alias ExLedger.Transactions.{TransactionStatus, TransactionType}
  alias __MODULE__

  import Ecto.Changeset
  import PolymorphicEmbed

  @transaction_types Application.compile_env!(:ex_ledger, :transaction_types)
  @deprecated_transaction_types Application.compile_env(
                                  :ex_ledger,
                                  :deprecated_transaction_types,
                                  []
                                )
  @default_status TransactionStatus.__enum_map__() |> List.first()
  @create_attrs ~w(amount type account_id)a
  @update_attrs ~w(status)a

  @type t :: %Transaction{
          amount: Decimal.t(),
          type: TransactionType.t(),
          status: TransactionStatus.t(),
          properties: map() | nil,
          account: Account.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "transactions" do
    field(:amount, :decimal)
    field(:type, TransactionType)
    field(:status, TransactionStatus, default: @default_status)

    polymorphic_embeds_one(:properties,
      types: @transaction_types,
      retain_unlisted_types_on_load: @deprecated_transaction_types,
      use_parent_field_for_type: :type,
      type_field_name: :type,
      on_type_not_found: :changeset_error,
      on_replace: :update
    )

    belongs_to(:account, Account)

    timestamps(type: :utc_datetime)
  end

  def create_changeset(attrs), do: create_changeset(%Transaction{}, attrs)

  def create_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @create_attrs)
    |> cast_polymorphic_embed(:properties)
    |> validate_required(@create_attrs)
    |> validate_amount()
    |> foreign_key_constraint(:account_id)
  end

  def update_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @update_attrs)
    |> cast_polymorphic_embed(:properties)
    |> validate_required(@update_attrs)
  end

  defp validate_amount(changeset) do
    changeset
    |> validate_number(:amount,
      greater_than: Decimal.new(0),
      message: "must be greater than zero"
    )
    |> check_constraint(:amount,
      name: :amount_must_be_greater_than_zero,
      message: "must be greater than zero"
    )
  end
end
