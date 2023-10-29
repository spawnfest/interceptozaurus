# http_intercept

Intercept and handle all outgoing HTTP requests in automated tests.

This package is useful in black-box integration testing. The developer can intercept
outgoing HTTP requests and handle them in a fake implementation of the external service.
This unlocks immense freedom to refactor the code, for example to swap out the API or HTTP client.

Inspired by [`@mswjs/interceptors`](https://www.npmjs.com/package/@mswjs/interceptors) and
[`httpmock`](https://hex.pm/packages/httpmock). Built on top of the amazing
[`mimic`](https://hex.pm/packages/mimic) package.

## Motivation

When building applications, it's common to make HTTP requests to multiple services. The requests
are made either directly via an HTTP client of choice or via a dedicated API client package.

Ideally, all code should be covered with automated tests and HTTP requests cause more trouble
than they should in this regard. Here's the list of different approaches to this problem with
their shortcomings:

1. Introducing a high level behaviour for the external service (as seen in [Mox's documentation](https://hexdocs.pm/mox/Mox.html#module-example)): the idea here is to introduce and code against a behaviour of the
external service:
    ```
    defmodule FooService do
      @callback get_foos() :: {:ok, list()} | {:error, term()}
    end
    ```

    While the behaviour can be easily replaced with another module in tests, the tests don't exercise
    the part of the application responsible for making the actual HTTP request. There might be some
    non-trivial logic hidden there (e.g. auth handling, response paging, cursor management).

2. Spinning up a dedicated replacement server (e.g. [Bypass](https://hex.pm/packages/bypass) and others):
the tests start a local server that can be programmed to respond with specific data. While this exercises
the code paths that make actual HTTP requests, all of them must be sent to a specifc host instead of the
real one. This is not ideal since it requires the production code to allow switching the host
and port for all requests; this might not even be possible if an API client is in use. Moreover,
the hostname is relevant for some services as it may contain the account name (e.g. Zendesk and Salesforce APIs).

3. Using pre-recorded responses (e.g. [exvcr](https://hex.pm/packages/exvcr)): the idea is to capture real
HTTP responses from a service and then reply them during tests. From our experience, maintaining the recorded
responses is a burden for any non-trivial workflow. The responses are static which makes them hard to reuse.

4. Using a test adapter for high-level HTTP clients (e.g. [Tesla's mock adapter](https://hexdocs.pm/tesla/Tesla.Mock.html)) or swapping the HTTP client in API clients (e.g. [AWS client](https://hexdocs.pm/aws/AWS.HTTPClient.html)):
while this gives the developer full control over the outgoing HTTP requests, it is only available
for selected HTTP and API clients. Additionally, in practice any larger application will use
multiple HTTP clients as transitive dependencies.

Since we're strong proponents of using integration tests over unit tests, we want to treat the
application as a black box and also limit the amount of code that exists only to enable automated
testing.

Ideally, either Erlang or Elixir would provide a single behaviour to which all HTTP clients would
adhere. This would enable the developer to use a single HTTP client for all their needs with
unified logging, telemetry, etc. Such client would also be easy to substitute for tests.

While the above is still not a reality, this package provides the alternative approach of intercepting
all outgoing HTTP requests in tests:

- [ ] Capture outgoing HTTP requests of all major HTTP clients,
- [ ] Provide convenience functions for HTTP request handlers,
- [ ] Allow pass-through for applications that call themselves.

## HTTP client support

The following table lists the support for various HTTP clients:

| Name | Status | Comments |
| ---- | ------ | -------- |
| [`:httpc`](https://www.erlang.org/doc/man/httpc.html) | 🏗️ WIP | |
| [`:hackney`](https://hex.pm/packages/hackney) | 🏗️ WIP | |
| [`HTTPoison`](https://hex.pm/packages/httpoison) | 🏗️ WIP | Uses `:hackney` |
| Your favourite HTTP client | 🏗️ WIP | Please open an issue! |

## Installation

The package is available on [Hex](https://hex.pm/packages/http_intercept) and can be installed
by adding `http_intercept` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:http_intercept, "~> 0.1.0"}
  ]
end
```

Documentation is available on [HexDocs](https://hexdocs.pm/http_intercept).

## Usage

(TODO)
