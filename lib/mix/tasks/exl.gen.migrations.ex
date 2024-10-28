defmodule Mix.Tasks.Exl.Gen.Migrations do
  use Mix.Task

  @repo Application.compile_env!(:ex_ledger, :repo)

  def run(_args) do
    generate_migration("create_enums")
    generate_migration("create_accounts")
    generate_migration("create_transactions")
  end

  defp generate_migration(template_name) do
    migrations_dir = "priv/#{to_snakecase(@repo)}/migrations"
    migration_name = "#{migrations_dir}/#{timestamp()}_#{template_name}.exs"

    migration_content =
      :ex_ledger
      |> :code.priv_dir()
      |> Path.join("templates/exl.gen.migrations/#{template_name}.ex")
      |> File.read!()
      |> EEx.eval_string(repo: @repo)

    File.mkdir_p!(migrations_dir)
    File.write!(migration_name, migration_content)

    Mix.shell().info(["\e[32m* creating\e[0m ", migration_name])

    Process.sleep(1000)
  end

  defp to_snakecase(module_name) do
    module_name
    |> Module.split()       
    |> List.last()
    |> Macro.underscore()
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
