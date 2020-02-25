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

  section [{Raxx.Logger, Raxx.Logger.setup(level: :info)}], [
    {%{method: :GET,  path: ["api", "status"]}, Handlers.ServerStatus },
    {%{method: :GET,  path: ["api", "free-spaces"]}, Handlers.AvailableSpace },
    {%{method: :GET,  path: ["api", "tickets", _barcode, "state"]}, Handlers.PaymentsState },
    {%{method: :POST, path: ["api", "tickets", _barcode, "payments"]}, Handlers.Payments },
    {%{method: :POST, path: ["api", "tickets", _barcode, "return"]}, Handlers.ReturnTickets},
    {%{method: :GET,  path: ["api", "tickets", _barcode]}, Handlers.Tickets },
    {%{method: :POST, path: ["api", "tickets"]}, Handlers.Tickets }
  ]

  section [{Raxx.Logger, Raxx.Logger.setup(level: :debug)}], [
    {_, Handlers.NotFound}
  ]
end

