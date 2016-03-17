defmodule Mix.Tasks.Peach.Start do
  use Mix.Task

  def run(args) do
    settings = Application.get_env(:maru, :http)
    IO.puts "Starting Peach"
    Mix.Task.run "run", run_args() ++ args
    IO.puts "Listening on port 8080"
  end

  defp run_args do
    if iex_running?, do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) && IEx.started?
  end
end
