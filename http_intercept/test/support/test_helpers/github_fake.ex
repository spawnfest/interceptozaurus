defmodule ExampleApp.TestHelpers.GitHubFake do
  @moduledoc """
  Fake implementation of GitHub.
  """

  use Agent
  alias HttpIntercept.RequestHandler
  @behaviour RequestHandler

  defmodule State do
    defstruct [:downtime, :users]

    def new() do
      %__MODULE__{downtime: false, users: Map.new()}
    end

    def downtime(state) do
      %{state | downtime: true}
    end

    def downtime?(state) do
      state.downtime
    end

    def create_user(%{users: users} = state, %{
          username: username,
          first_name: first_name,
          last_name: last_name
        }) do
      id = map_size(users) + 1
      node_id = Base.encode64("04:User#{id}")
      created_at = DateTime.utc_now() |> DateTime.to_iso8601()
      name = "#{first_name} #{last_name}"

      user = %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/1234567?v=4",
        "bio" => nil,
        "blog" => nil,
        "company" => nil,
        "created_at" => created_at,
        "email" => nil,
        "events_url" => "https://api.github.com/users/#{username}/events{/privacy}",
        "followers" => 0,
        "followers_url" => "https://api.github.com/users/#{username}/followers",
        "following" => 0,
        "following_url" => "https://api.github.com/users/#{username}/following{/other_user}",
        "gists_url" => "https://api.github.com/users/#{username}/gists{/gist_id}",
        "gravatar_id" => "",
        "hireable" => nil,
        "html_url" => "https://github.com/#{username}",
        "id" => id,
        "location" => "City, Country",
        "login" => "#{username}",
        "name" => name,
        "node_id" => node_id,
        "organizations_url" => "https://api.github.com/users/#{username}/orgs",
        "public_gists" => 0,
        "public_repos" => 0,
        "received_events_url" => "https://api.github.com/users/#{username}/received_events",
        "repos_url" => "https://api.github.com/users/#{username}/repos",
        "site_admin" => false,
        "starred_url" => "https://api.github.com/users/#{username}/starred{/owner}{/repo}",
        "subscriptions_url" => "https://api.github.com/users/#{username}/subscriptions",
        "twitter_username" => nil,
        "type" => "User",
        "updated_at" => created_at,
        "url" => "https://api.github.com/users/#{username}"
      }

      %{state | users: Map.put(users, username, user)}
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

  def downtime() do
    Agent.update(via(), &State.downtime/1)
  end

  def downtime?() do
    Agent.get(via(), &State.downtime?/1)
  end

  def register_user(params) do
    Agent.update(via(), &State.create_user(&1, params))
  end

  def get_user(username) do
    Agent.get(via(), &State.get_user(&1, username))
  end

  @user_not_found %{
    "message" => "Not Found",
    "documentation_url" => "https://docs.github.com/rest/users/users#get-a-user"
  }

  defp check_downtime() do
    if downtime?() do
      RequestHandler.json(500, %{})
    else
      :ok
    end
  end

  @impl HttpIntercept.RequestHandler
  def handle_request(:get, "https://api.github.com/users/" <> username, _headers, _body) do
    with :ok <- check_downtime() do
      case get_user(username) do
        nil -> RequestHandler.json(404, @user_not_found)
        user -> RequestHandler.json(200, user)
      end
    end
  end
end
