defmodule ParkaLot.Maybe do
    def ok(value) do
      {:ok, value}
    end

    def error(reason) do
      {:error, reason}
    end
  end
