defmodule ExLedger.TestRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :ex_ledger,
    adapter: Ecto.Adapters.Postgres
end
