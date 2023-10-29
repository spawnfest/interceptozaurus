defmodule ExampleApp do
  @moduledoc """
  An example application that fetches data from Hex (using an HTTP client)
  and from GitHub (via a dedicated API client which wraps HTTPoison).

  Note how we can write simple code and the testability comes from intercepting
  the outgoing HTTP requests.
  """

  def fetch_user_info(username) do
    with {:ok, hex_user} <- fetch_hex_user(username),
         {:ok, github_user} <- fetch_github_user(username) do
      {:ok, %{hex: hex_user, github: github_user}}
    end
  end

  def fetch_hex_user(username) do
    # Use :httpc to fetch the Hex user.
    # Hex doesn't seem to have public API so let's just scrape the website.
    case :httpc.request("https://hex.pm/users/#{username}") do
      {:ok, {{_version, status, _status_text}, _http_headers, _response_body}} ->
        result =
          if status == 200 do
            %{"active" => true}
          else
            nil
          end

        {:ok, result}

      {:error, term} ->
        {:error, term}
    end
  end

  def fetch_github_user(username) do
    # Tentacat uses HTTPoison which uses :hackney underneath.
    case Tentacat.Users.find(Tentacat.Client.new(), username) do
      {200, body, _response} -> {:ok, body}
      {404, _body, _response} -> {:ok, nil}
      {status, _body, _response} -> {:error, "HTTP error #{status}"}
    end
  end
end
