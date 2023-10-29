defmodule HttpIntercept.RequestHandler do
  @moduledoc """
  A behaviour for handlers of intercepted requests.
  """

  # TODO: improve typespec.
  @callback handle_request(
              method :: String.t(),
              url :: String.t(),
              headers :: list(),
              body :: term()
            ) ::
              {:ok, status :: integer(), headers :: list(), body :: term} | {:error, term()}

  def json(status, body, headers \\ []) do
    {:ok, status, [{"content-type", "application/json"} | headers], Jason.encode!(body)}
  end
end
