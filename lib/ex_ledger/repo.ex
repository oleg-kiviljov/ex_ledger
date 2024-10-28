defmodule ExLedger.Repo do
  @repo Application.compile_env!(:ex_ledger, :repo)

  alias Ecto.Changeset

  @spec one(queryable :: Ecto.Queryable.t(), opts :: Keyword.t()) ::
          Ecto.Schema.t() | term() | nil
  def one(queryable, opts) do
    @repo.one(queryable, opts)
  end

  @spec transaction(fun :: fun()) :: {:ok, any()} | {:error, atom()}
  def transaction(fun) do
    @repo.transaction(fn repo ->
      Function.info(fun, :arity)
      |> case do
        {:arity, 0} -> fun.()
        {:arity, 1} -> fun.(repo)
      end
      |> case do
        {:ok, result} -> result
        {:error, reason} -> repo.rollback(reason)
      end
    end)
  end

  @spec insert(changeset :: Ecto.Changeset.t()) :: {:ok, any()} | {:error, Ecto.Changeset.t()}
  def insert(changeset) do
    changeset
    |> @repo.insert()
    |> handle_result()
  end

  @spec update(changeset :: Ecto.Changeset.t()) :: {:ok, any()} | {:error, Ecto.Changeset.t()}
  def update(changeset) do
    changeset
    |> @repo.update()
    |> handle_result()
  end

  defp handle_result({:error, changeset}), do: {:error, unnest_changeset_errors(changeset)}
  defp handle_result(result), do: result

  defp unnest_changeset_errors(changeset) do
    %Changeset{changeset | errors: collect_changeset_errors(changeset)}
  end

  defp collect_changeset_errors(%Changeset{errors: errors, changes: changes}) do
    changes
    |> Enum.flat_map(fn {key, value} ->
      case value do
        %Changeset{} -> collect_changeset_errors(value) |> Enum.map(&prepend_key(key, &1))
        _ -> []
      end
    end)
    |> Kernel.++(errors)
  end

  defp prepend_key(key, {field, error}), do: {:"#{key}_#{field}", error}

  # defp repo do
  #   Application.fetch_env!(:ex_ledger, :repo)
  # end
end
