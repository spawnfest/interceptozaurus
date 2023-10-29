defmodule HttpIntercept.Stubs.Httpc do
  @moduledoc """
  Mimic stub for the :httpc module.
  """

  def maybe_enable() do
    # Since :httpc is a built-in Erlang module, we always stub it.
    Mimic.copy(:httpc)

    Mimic.stub(:httpc, :request, fn url ->
      # TODO: transform the args :httpc -> interceptor.
      case HttpIntercept.handle_request(:get, url, [], nil) do
        # TODO: transform the result interceptor -> :httpc.
        {:ok, status, headers, body} ->
          {:ok,
           {
             {
               ~c"HTTP/1.1",
               status,
               # TODO: status text
               status |> to_string() |> to_charlist()
             },
             Enum.map(headers, fn {name, value} -> {to_charlist(name), to_charlist(value)} end),
             to_charlist(body)
           }}

        # TODO: transform error.
        error ->
          error
      end
    end)
  end
end
