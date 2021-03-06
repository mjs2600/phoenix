defmodule Mix.Tasks.Phoenix.New do
  use Mix.Task

  @shortdoc "Creates Phoenix application"

  @template_dir "template"

  def run([]) do
    Mix.shell.info """
    Supply application name and destination path.

    e.g.
      mix phoenix.new photo_blog /home/johndoe/
    """
  end

  @doc """
  Creates Phoenix application.
  """
  def run([name, path]) do
    application_name = Mix.Utils.underscore(name)
    application_module = Mix.Utils.camelize(name)
    project_path = make_project_path(path, application_name)

    bindings = [application_name: application_name,
                application_module: application_module]

    Mix.Generator.create_directory(project_path)

    lc source_path inlist template_files do
      destination_path = make_destination_path(project_path, source_path, application_name)

      if File.dir?(source_path) do
        Mix.Generator.create_directory(destination_path)
      else
        contents = EEx.eval_file(source_path, bindings)

        Mix.Generator.create_file(destination_path, contents)
      end
    end
  end

  defp make_project_path(path, application_name) do
    basename = Mix.Utils.underscore(Path.basename(path))

    if basename == application_name do
      path
    else
      Path.join(path, application_name)
    end
  end

  defp template_files do
    file_pattern = Path.join(template_path, "**/*")

    Path.wildcard(file_pattern)
  end

  defp make_destination_path(project_path, file, application_name) do
    new_path = String.replace(file, "application_name", application_name)
    relative_path = Path.relative_to(new_path, template_path)

    Path.join(project_path, relative_path)
  end

  defp template_path do
    {:ok, root_path} = File.cwd

    Path.join(root_path, @template_dir)
  end
end
