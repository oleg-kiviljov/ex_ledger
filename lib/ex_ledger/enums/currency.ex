defmodule ExLedger.Enums.Currency do
  @moduledoc """
  Currency enum.
  """

  use EctoEnum,
    type: :currency,
    enums: Application.compile_env!(:ex_ledger, :supported_currencies)
end
