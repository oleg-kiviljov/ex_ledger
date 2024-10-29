defmodule ExLedger.TransactionTypes.CryptoWithdrawal do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @attrs ~w(to_address confirmations)a

  @primary_key false
  embedded_schema do
    field :to_address, :string
    field :confirmations, :integer
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
