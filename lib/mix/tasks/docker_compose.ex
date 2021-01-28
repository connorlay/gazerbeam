defmodule Mix.Tasks.DockerCompose do
  @moduledoc """
  `Mix.Task` for controlling `docker-compose` when developing and testing `Gazerbeam`

  ## Arguments

  - `up`: starts all containers in the background
  - `down`: stops all containers if running
  - `drop`: stops all containers and removes orphans and volumes
  """
  @shortdoc "Use docker-compose for development and testing"

  use Mix.Task

  @impl true
  def run(["up"]) do
    Mix.shell().cmd("docker-compose up --detach")
  end

  def run(["down"]) do
    Mix.shell().cmd("docker-compose down")
  end

  def run(["drop"]) do
    Mix.shell().cmd("docker-compose down --remove-orphans --volumes")
  end

  def run(_) do
    Mix.Task.run("help", ["docker_compose"])
  end
end
