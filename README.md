# ParkaLot Server
![Plogo](https://user-images.githubusercontent.com/6124495/75305074-cb87dd80-5823-11ea-904d-049e92bc3e7e.png)
![giphy](https://user-images.githubusercontent.com/6124495/75306280-57e7cf80-5827-11ea-9f9c-a5e44a2903bd.gif)

## how to run in your local env (dev)

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

HttpCode == 200 with always a payload in this manner
``` js
{
  "data": {entity} //entity is a JS Object with the data about entity or the performed action as well
}
```
### Response Error :x: :office:(at business Level)
HttpCode == 200 with always a payload in this manner, it's a similar idea to GraphQL
This kinda errors shall arise from the actions or Entities modules
``` js
{
  "error": reason //reason is a string with error description
}
```
### Response Error:x: :computer:(Server Level) but **maybe** it wouldn't contain a payload
HttpCode in [30X, 40X, 50X]
This kinda errors shall arise from the handlers or from an un expected situation like an outage.
``` js
{
  "error": reason //reason is a string with error description
}
```

## API Flow descriptions


