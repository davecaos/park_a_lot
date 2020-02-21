defmodule ParkaLot.Tickets.Datatypes.Time do
    alias ParkaLot.Maybe


    @in_seconds_15minutes 60*15
    # Sharing private module constant through a function call
    def in_seconds_15minutes(), do: @in_seconds_15minutes 

    def diff_time_dates(date, minus_second_date ) do
        date_in_seconds = DateTime.to_unix(DateTime.from_naive!(date, "Etc/UTC"))
        minus_second_date_in_seconds = DateTime.to_unix(DateTime.from_naive!(minus_second_date, "Etc/UTC"))
        date_in_seconds - minus_second_date_in_seconds
    end

    def diff_date_and_now_in_seconds(previous_date) do
        now_naive_date = NaiveDateTime.utc_now()
        diff_time_dates(now_naive_date, previous_date )
    end
end
