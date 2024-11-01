defmodule ExLedger.Macros do
  defmacro maybe_belongs_to(belongs_to) do
    quote do
      if belongs_to = unquote(belongs_to) do
        name = Keyword.fetch!(belongs_to, :name)
        schema = Keyword.fetch!(belongs_to, :schema)
        opts = Keyword.get(belongs_to, :opts, [])

        belongs_to name, schema, opts
      end
    end
  end
end
