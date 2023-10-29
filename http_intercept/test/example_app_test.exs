defmodule ExampleAppTest do
  use ExampleApp.Case, async: true

  alias ExampleApp.TestHelpers.HexFake, as: Hex
  alias ExampleApp.TestHelpers.GitHubFake, as: GitHub

  describe "fetching user info" do
    test "fetches user data from Hex and GitHub" do
      Hex.create_user("jane")
      GitHub.register_user(%{username: "jane", first_name: "Jane", last_name: "Smith"})

      assert {:ok,
              %{
                hex: %{
                  "active" => true
                },
                github: %{
                  "login" => "jane",
                  "name" => "Jane Smith",
                  "type" => "User",
                  "url" => "https://api.github.com/users/jane"
                }
              }} = ExampleApp.fetch_user_info("jane")
    end

    test "returns empty data if the user does not exist" do
      assert {:ok,
              %{
                hex: nil,
                github: nil
              }} = ExampleApp.fetch_user_info("jane")
    end

    test "returns error if any service experiences downtime" do
      GitHub.downtime()

      assert {:error, _reason} = ExampleApp.fetch_user_info("jane")
    end
  end
end
