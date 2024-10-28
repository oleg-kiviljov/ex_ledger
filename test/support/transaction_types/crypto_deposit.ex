defmodule ExLedger.TransactionTypes.CryptoDeposit do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @attrs ~w(from_address confirmations)a

  @primary_key false
  embedded_schema do
    field :from_address, :string
    field :confirmations, :integer
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
