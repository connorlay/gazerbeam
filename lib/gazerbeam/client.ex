defmodule Gazerbeam.Client do
  @moduledoc """
  GitHub REST API v3 client
  """

  @typedoc """
  Owner of a GitHub repository
  """
  @type owner :: String.t()

  @typedoc """
  Name of a GitHub repository
  """
  @type name :: String.t()

  @typedoc """
  GitHub JSON response or HTTP error
  """
  @type response :: {:ok, term} | {:error, HTTPoison.Response.t()}

  @doc """
  Fetch GitHub repository information
  """
  @callback get_repository(owner(), name()) :: response()

  @doc """
  Fetch all Stargazers for a given repository
  """
  @callback get_stargazers(owner(), name()) :: response()

  @doc """
  Fetch the current rate limit
  """
  @callback get_rate_limit() :: response()

  @doc """
  Returns the impl module for the current environment

  Returns either `Gazerbeam.Client.GitHub` or `Gazerbeam.Client.GitHubMock`
  """
  def impl() do
    Application.get_env(:gazerbeam, __MODULE__)[:impl]
  end
end
