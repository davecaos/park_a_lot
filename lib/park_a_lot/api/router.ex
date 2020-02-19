defmodule ParkaLot.API.Router do
  use Raxx.Router
  alias ParkaLot.API.Handlers

  def stack(config) do
    Raxx.Stack.new(
      [
        # Add global middleware here.
      ],
      {__MODULE__, config}
    )
  end

  # Call GreetUser and in WWW dir AND call into lib
  section [{Raxx.Logger, Raxx.Logger.setup(level: :info)}], [
    {%{path: ["api", "tickets"]}, Handlers.Tickets },
    {%{path: ["api", "tickets", _barcode]}, Handlers.Tickets },
    {%{path: ["api", "status"]}, Handlers.Status }
  ]

  section [{Raxx.Logger, Raxx.Logger.setup(level: :debug)}], [
    {_, Handlers.NotFound}
  ]
end

