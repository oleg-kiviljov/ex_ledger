defmodule ExLedger.AccountTypes.CryptoAccount do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @attrs ~w(address blockchain)a

  @primary_key false
  embedded_schema do
    field(:address, :string)
    field(:blockchain, :string)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
