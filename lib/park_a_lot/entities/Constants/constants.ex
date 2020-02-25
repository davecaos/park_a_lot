defmodule ParkaLot.Entities.Constants do

    @parking_cost_by_hour 2
    def parking_cost_by_hour, do: @parking_cost_by_hour 

    @in_seconds_15minutes 60*15
    def in_seconds_15minutes(), do: @in_seconds_15minutes 

    @created_state "created"
    @paid_state "paid"
    @returned_state "returned"
    @valid_state_types [ @created_state, @paid_state, @returned_state]

    def created_state, do: @created_state 
    def paid_state, do: @paid_state 
    def returned_state, do: @returned_state 
  
    @credit_card_state "credit card"
    @debit_card_state "debit card"
    @cash_state "cash"
    @valid_payment_types [ @cash_state, @debit_card_state, @credit_card_state]

    def credit_card_state, do: @credit_card_state 
    def debit_card_state, do: @debit_card_state 
    def cash_state, do: @cash_state 
end
