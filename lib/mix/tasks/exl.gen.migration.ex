defmodule Mix.Tasks.Exl.Gen.Migration do
  use Mix.Task

  @migration_dir "priv/repo/migrations"

  def run(_args) do
    generate_migration_file("create_enums")
    # generate_migration_file("create_accounts")
    # generate_migration_file("create_transactions")
  end

  defp host_app do
    Mix.Project.config().app
  end

  defp generate_migration_file(migration_name) do
    Mix.Task.run("ecto.gen.migration", [migration_name])

    # timestamp = timestamp()
    # migration_file_name = "#{@migration_dir}/#{timestamp}_#{migration_name}.exs"

    # # Ensure the migrations directory exists
    # File.mkdir_p!(@migration_dir)

    # # Create the migration file with the specified content
    # File.write!(migration_file_name, generate_migration_content(content))
    # Mix.shell().info("Migration file created: #{migration_file_name}")
  end

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
