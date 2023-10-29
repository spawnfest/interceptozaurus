defmodule ExampleApp.Case do
  @moduledoc """
  Custom ExUnit case for tests.
  """

  use ExUnit.CaseTemplate

  setup do
    start_supervised!({Registry, [keys: :unique, name: ExampleApp.TestHelpers.FakesRegistry]})
    start_supervised!({ExampleApp.TestHelpers.HexFake, self()})
    start_supervised!({ExampleApp.TestHelpers.GitHubFake, self()})

    # TODO: figure out duplicate registrations.
    HttpIntercept.add_handler("hex.pm", ExampleApp.TestHelpers.HexFake)
    HttpIntercept.add_handler("api.github.com", ExampleApp.TestHelpers.GitHubFake)

    :ok
  end
end
