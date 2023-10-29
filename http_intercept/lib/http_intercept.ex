defmodule HttpIntercept do
  @moduledoc """
  Outgoing HTTP request interceptor.
  """

  use Agent

  @doc """
  Enables intercepting of all HTTP requests.
  """
  def enable() do
    # TODO: handle duplicate enable calls.
    # TODO: can we globally replace HTTP-related modules without enforcing global mode?
    {:ok, _pid} = Agent.start_link(fn -> [] end, name: __MODULE__)
    Mimic.set_mimic_global()
    HttpIntercept.Stubs.Httpc.maybe_enable()
    HttpIntercept.Stubs.Hackney.maybe_enable()
    # TODO: other HTTP clients.
  end

  @doc """
  Adds a requets handler that matches the provided URL pattern.
  """
  def add_handler(url_pattern, handler) do
    # TODO: check if interception is enabled.
    # TODO: document that we handle both strings and regexes for url_pattern.
    Agent.update(__MODULE__, fn handlers -> handlers ++ [{url_pattern, handler}] end)
  end

  @doc false
  def handle_request(method, url, headers, body) do
    handlers = Agent.get(__MODULE__, fn handlers -> handlers end)

    case Enum.find(handlers, fn {url_pattern, _handler} -> url =~ url_pattern end) do
      {_url_pattern, handler} ->
        call_handler(handler, method, url, headers, body)

      nil ->
        raise """
        No handler was set up for the following outgoing HTTP request:

            #{String.upcase(to_string(method))} #{url}

        Make sure to call HttpIntercept.add_handler(<pattern>, handler) before any request is made.
        #{length(handlers)} handler(s) registered.
        """
    end
  end

  # TODO: support MFA and anonymous functions.
  defp call_handler(module, method, url, headers, body) when is_atom(module) do
    # Double-check that the handler is adhering to the interface.
    # TODO: improve the checks.
    case module.handle_request(method, url, headers, body) do
      {:ok, status, headers, body} -> {:ok, status, headers, body}
      {:error, reason} -> {:error, reason}
    end
  end
end
