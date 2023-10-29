defmodule HttpIntercept.Stubs.Hackney do
  @moduledoc """
  Mimic stub for :hackney.
  """

  def maybe_enable() do
    # TODO: figure out if Hackney is in use.
    Mimic.copy(:hackney)

    Mimic.stub(:hackney, :request, fn method, url, headers, body, _options ->
      # TODO: handle the with_body option.
      # TODO: handle HEAD requests.
      # TODO: transform the args :hackney -> interceptor.
      case HttpIntercept.handle_request(method, url, headers, body) do
        # TODO: transform the result interceptor -> :hackney.
        {:ok, status, headers, body} ->
          # TODO: the last element should be a ref.
          {:ok, status, headers, body}

        # TODO: transform error.
        error ->
          error
      end
    end)

    Mimic.stub(:hackney, :body, fn ref, _max_length ->
      # TODO: ref is actually the body.
      {:ok, ref}
    end)
  end
end
