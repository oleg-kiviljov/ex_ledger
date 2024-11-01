defmodule ExLedger.Accounts.Account do
  @moduledoc """
  Account schema.
  """
  use Ecto.Schema

  alias ExLedger.Accounts.{AccountCurrency, AccountStatus, AccountType}
  alias ExLedger.Transactions.Transaction
  alias __MODULE__

  import Ecto.Changeset
  import ExLedger.Macros
  import PolymorphicEmbed

  @account_types Application.compile_env!(:ex_ledger, :account_types)
  @deprecated_account_types Application.compile_env(:ex_ledger, :deprecated_account_types, [])
  @account_belongs_to Application.compile_env(:ex_ledger, :account_belongs_to)
  @default_status AccountStatus.__enum_map__() |> List.first()
  @create_attrs ~w(currency type)a
  @update_attrs ~w(balance status)a

  @type t :: %Account{
          balance: Decimal.t(),
          currency: AccountCurrency.t(),
          type: AccountType.t(),
          status: AccountStatus.t(),
          properties: map() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "accounts" do
    field(:balance, :decimal, default: Decimal.new(0))
    field(:currency, AccountCurrency)
    field(:type, AccountType)
    field(:status, AccountStatus, default: @default_status)

    polymorphic_embeds_one(:properties,
      types: @account_types,
      retain_unlisted_types_on_load: @deprecated_account_types,
      use_parent_field_for_type: :type,
      type_field_name: :type,
      on_type_not_found: :changeset_error,
      on_replace: :update
    )

    has_many(:transactions, Transaction)

    maybe_belongs_to(@account_belongs_to)

    timestamps(type: :utc_datetime)
  end

  def create_changeset(attrs), do: create_changeset(%Account{}, attrs)

  def create_changeset(account, attrs) do
    account
    |> cast(attrs, @create_attrs)
    |> cast_polymorphic_embed(:properties, required: true)
    |> validate_required(@create_attrs)
  end

  def update_changeset(account, attrs) do
    account
    |> cast(attrs, @update_attrs)
    |> cast_polymorphic_embed(:properties, required: true)
    |> validate_required(@update_attrs)
    |> validate_balance()
  end

  defp validate_balance(changeset) do
    changeset
    |> validate_number(:balance,
      greater_than_or_equal_to: Decimal.new(0),
      message: "must be greater than or equal to zero"
    )
    |> check_constraint(:balance,
      name: :balance_must_be_greater_than_or_equal_to_zero,
      message: "must be greater than or equal to zero"
    )
  end
end
