defmodule Mix.Tasks.Exl.Gen.Migration do
  use Mix.Task

  @migration_dir "priv/repo/migrations"

  def run(_args) do
    Mix.Project.config() |> IO.inspect()

    # generate_migration_file("create_enums")
    # generate_migration_file("create_accounts")
    # generate_migration_file("create_transactions")
  end

  # defp parse_args(args) do
  #   case args do
  #     [migration_name | content] ->
  #       {migration_name, Enum.join(content, " ")}
  #     _ ->
  #       Mix.raise("Usage: mix generate_migration <migration_name> <content>")
  #   end
  # end

  # defp generate_migration_file(migration_name, content) do
  #   timestamp = timestamp()
  #   migration_file_name = "#{@migration_dir}/#{timestamp}_#{migration_name}.exs"

  #   # Ensure the migrations directory exists
  #   File.mkdir_p!(@migration_dir)

  #   # Create the migration file with the specified content
  #   File.write!(migration_file_name, generate_migration_content(content))
  #   Mix.shell().info("Migration file created: #{migration_file_name}")
  # end

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
