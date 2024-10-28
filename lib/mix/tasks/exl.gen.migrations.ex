defmodule Mix.Tasks.Exl.Gen.Migrations do
  use Mix.Task

  @repo Application.compile_env!(:ex_ledger, :repo)
  @templates_dir "priv/templates/exl.gen.migrations"
  @migrations_dir "priv/repo/migrations"

  def run(_args) do
    generate_migration("create_enums")
    generate_migration("create_accounts")
    generate_migration("create_transactions")
  end

  defp generate_migration(template_name) do
    migration_name = "#{@migrations_dir}/#{timestamp()}_#{template_name}.exs"

    migration_content =
      "#{@templates_dir}/#{template_name}.ex"
      |> read_template!()
      |> EEx.eval_string(repo: @repo)

    File.mkdir_p!(@migrations_dir)
    File.write!(migration_name, migration_content)

    Mix.shell().info(["\e[32m* creating\e[0m ", migration_name])
  end

  defp read_template!(template_path) do
    File.exists?(template_path) && File.read!(template_path)
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)

  # defp host_app do
  #   Mix.Project.config().app
  # end

  # Mix.Task.run("ecto.gen.migration", [migration_name])

  # defp timestamp do
  #   DateTime.utc_now()
  #   |> DateTime.to_unix(:second)
  #   |> Integer.to_string()
  # end

  # defp generate_migration_content(content) do
  #   """
  #   defmodule MyApp.Repo.Migrations.#{String.capitalize(content)} do
  #     use Ecto.Migration

  #     def change do
  #       # Your migration content here
  #       #{content}
  #     end
  #   end
  #   """
  # end
end
