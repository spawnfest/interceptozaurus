Hey, there! 👋

Here's my entry for SpawnFest 2023. The goal was to build a package that helps writing
black-box integration tests for applications that make outgoing HTTP requests.

Due to time limitations the package and the example app live in the same Elixir project
under [http_intercept](http_intercept) and the code is sprinkled with TODO comments.

The suggested order of reviewing things:

- [http_intercept/README.md](http_intercept/README.md): motivation for this package,
- [http_intercept/lib/example_app.ex](http_intercept/lib/example_app.ex): an example application,
- [http_intercept/test/example_app_test.exs](http_intercept/test/example_app_test.exs): an integration test of the example application,
- [http_intercept/lib/http_intercept.ex](http_intercept/lib/http_intercept.ex): the core of the package,
- [http_intercept/test/support/](http_intercept/test/support/): the support code needed to make the integration tests simple to read and write.

Feel free to `mix deps.get && mix test` to run the integration tests for the example application.


Thanks for taking the time to review this entry! Had fun doing this!

Best,
Stefan
