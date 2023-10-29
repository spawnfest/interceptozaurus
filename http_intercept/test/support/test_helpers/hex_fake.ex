defmodule ExampleApp.TestHelpers.HexFake do
  @moduledoc """
  Fake implementation of Hex.
  """

  use Agent
  alias HttpIntercept.RequestHandler
  @behaviour RequestHandler

  defmodule State do
    defstruct [:users]

    def new() do
      %__MODULE__{users: Map.new()}
    end

    def create_user(%{users: users} = state, username) do
      %{state | users: Map.put(users, username, true)}
    end

    def get_user(%{users: users}, username) do
      Map.get(users, username)
    end
  end

  defp via(test_pid \\ nil) do
    {:via, Registry, {ExampleApp.TestHelpers.FakesRegistry, {__MODULE__, test_pid || self()}}}
  end

  def start_link(test_pid) do
    Agent.start_link(fn -> State.new() end, name: via(test_pid))
  end

  def create_user(username) do
    Agent.update(via(), &State.create_user(&1, username))
  end

  def get_user(username) do
    Agent.get(via(), &State.get_user(&1, username))
  end

  @impl RequestHandler
  def handle_request(:get, "https://hex.pm/users/" <> username, _headers, _body) do
    case get_user(username) do
      true -> {:ok, 200, ["content-type": "text/html"], "<html></html>"}
      nil -> {:ok, 404, ["content-type": "text/html"], "<html></html>"}
    end
  end
end
