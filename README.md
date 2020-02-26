# ParkaLot Server
![Plogo](https://user-images.githubusercontent.com/6124495/75305074-cb87dd80-5823-11ea-904d-049e92bc3e7e.png)
![giphy](https://user-images.githubusercontent.com/6124495/75306280-57e7cf80-5827-11ea-9f9c-a5e44a2903bd.gif)


## Hosted server at Heroku with  postsgres DB
:point_right: :point_right: :link: https://immense-coast-01186.herokuapp.com/

## how to run in your local env (development)

### With Docker :whale:

- Start your service with `docker-compose up`
- Run project test suite with `docker-compose run park_a_lot mix test`
- Start IEx session in running service
      # Find a container id using docker ps
      docker exec -it <container-id> bash

      # In container
      iex --sname debug --remsh app@$(hostname)

## Alternatively, you can still run the project directly, without docker:

- Start just only the **database service** with `docker-compose up db`
- Install dependencies with `mix deps.get`
- prepare the database using `mix do ecto.create, ecto.migrate`
- Start your service with `iex -S mix`

## HTTP API Abstract OK/Error return description

### Response OK :ok: :white_check_mark:

**HttpCode == 200** with always a payload in this manner.
``` js
{
  "data": {entity} //entity is a JS Object with the data about entity or the performed action as well
}
```
### Response Error :x: :briefcase: (at business Level)
**HttpCode == 200** with always a payload in this manner.
It's a similar idea to GraphQL

This kinda errors shall arise from the actions or Entities modules
``` js
{
  "error": reason //reason is a string with error description
}
```
### Response Error:x: :computer: (Server Level) but **maybe** it wouldn't contain a payload
**HttpCode in [30X, 40X, 50X]**

This kinda errors shall arise from the handlers or from an un expected situation like an outage.
``` js
{
  "error": reason //reason is a string with error description
}
```

## API Flow descriptions

### Task #1
**Create a new parking ticket** 

      This happen when a user enter with their vehicle at the parking lot, the machine at the gate 
      make a POST to {server_url}/api/tickets/ then if there are at least an available slot
      the server will return a new ticket to open the gate

``` js
//Response
{
    "data": {
        "id": "00000000000000001", // the id field is the barcode in Hex
        "inserted_at": "2020-02-23T03:11:50"
    }
}
```

### Task #2
**Get the cost of a parking ticket** 

      The machine at the gate could calculate the cost of a especific ticket doing a
      make a POST to {server_url}/api/tickets/{barcode_hexa} .
      The client will always pay for a full hour

``` js
//Response
{
    "data": {
        "cost": 2,
        "currency": "euros"
    }
}
```
### Task #3
**get the cost of a parking ticket** 

      The machine at the gate could calculate the cost of a especific ticket,
      The client must paid their ticket before leaving the parking slot, the payment will be informed by hitting
      POST to {server_url}/api/tickets/{barcode_hexa}/payments with "payment_method" at json body

``` js
//Request
// POST to {server_url}/api/tickets/{barcode_hexa}/payments 
{
      "payment_method": "cash" // ["cash", "debit card", "credit car"]
}
```
``` js
//Response
{
    "data": {
        "id": "00000000000001005",
        "payment_method": "cash",
        "state": "paid",
        "inserted_at": "2020-02-23T04:48:38"
    }
}
```
### Task #4
**Know if a ticket is paid or inpaid state** 

      The machine at the gate could calculate the payment status/state of a especific ticket,
      The client must paid their ticket before leaving the parking slot, the payment will be informed by hitting
      GET to {server_url}/api/tickets/{barcode_hexa}/state

``` js
//Response
{
    "data": {
        "id": "00000000000001005",
        "payment_method": "cash",
        "state": "paid",
        "inserted_at": "2020-02-23T04:48:38"
    }
}
```
### Task #5
**Calculate free space at parking lot** 

      The machine at the gate could calculate the payment available spaces at the parking,
      The client must paid their ticket before leaving the parking slot, the payment will be informed by hitting
      GET to {server_url}/api/free-spaces

``` js
//Response
{
    "data": {
        "available_free_space": 36
    }
}
```

### Task #6 extra
**Create and endpoint to return the ticket at the gate** 

      The must return their parking ticket at the gate for leaving the place with their car,
      The client must paid their ticket before leaving the parking slot, the payment will be informed by hitting
      GET to {server_url}/api/tickets/{barcode_hexa}/retrun

``` js
//Response
{
    "data": {
        "id": 1,
        "payment_method": "cash",
        "state": "returned",
        "inserted_at": "2020-02-23T03:11:50"
    }
}
```
