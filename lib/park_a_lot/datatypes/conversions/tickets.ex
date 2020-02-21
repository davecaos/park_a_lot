defmodule ParkaLot.Tickets.Conversion do
    alias ParkaLot.Maybe

    @base16 16

    def to_id_from(bardcode) do
        case Integer.parse(bardcode, @base16) do
            {ticket_id_in_decimal, ""} -> 
                Maybe.ok(ticket_id_in_decimal)
            _error ->
                Maybe.error("Invalid ticket id")
        end
    end

    def to_hex_barcode_from(ticket_id) do
        id_hexa = Integer.to_string(ticket_id, @base16)
        padding_size = 16 - String.length(id_hexa)
        padding = for _ <- 0..padding_size, do: '0'
        Maybe.ok("#{padding}" <>  id_hexa)
    end


end
