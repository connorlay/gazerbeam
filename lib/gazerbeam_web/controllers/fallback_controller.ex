defmodule GazerbeamWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use GazerbeamWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(GazerbeamWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, %HTTPoison.Response{status_code: 404}}) do
    call(conn, {:error, :not_found})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(GazerbeamWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :malformed_date}) do
    conn
    |> put_status(:bad_request)
    |> put_view(GazerbeamWeb.ErrorView)
    |> render(:"400")
  end
end
