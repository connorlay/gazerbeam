defmodule Gazerbeam.Client.GitHub do
  @moduledoc false

  @behaviour Gazerbeam.Client

  @impl true
  def get_repository(owner, name) do
    "repos/#{owner}/#{name}"
    |> Tentacat.get(build_client())
    |> decode()
  end

  @impl true
  def get_stargazers(owner, name) do
    "repos/#{owner}/#{name}/stargazers"
    |> Tentacat.get(
      build_client(),
      pagination: :auto
    )
    |> decode()
  end

  @impl true
  def get_rate_limit() do
    "rate_limit"
    |> Tentacat.get(build_client())
    |> decode()
  end

  defp build_client() do
    access_token = Application.get_env(:gazerbeam, Gazerbeam.Client)[:access_token]

    if access_token do
      Tentacat.Client.new(%{access_token: access_token})
    else
      Tentacat.Client.new()
    end
  end

  defp decode({200, data, _}), do: {:ok, data}
  defp decode({_, _, resp}), do: {:error, resp}
end
