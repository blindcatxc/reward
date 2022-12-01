# README

# Prerequisite
* install docker in the device(https://docs.docker.com/get-docker/)

# Get Started
* clone the repo
```sh
  git clone git@github.com:blindcatxc/reward.git
```
* start the web server
```sh
  docker-compose up web
```
** the server default port is 3001, if you want to customize that, feel free to modify the line 20 in docker-compose.yml

# Api Spec
## Create transaction
URL: `POST http://localhost:3001/transactions`
URL Params: null
request body: null
* curl command to call server
```sh
curl --location --request POST 'http://localhost:3001/transactions' \
--header 'Content-Type: application/json' \
--data-raw '{ "points": 150, "timestamp": "2022-10-31T10:00:00Z", "payer": "AAA" }'
```
Request Sample:
```ruby
# happy path, response status code: 201
# request body:
{ "points": -250, "timestamp": "2022-10-31T10:00:00Z", "payer": "AAA" }
# response body:
{}

# error sample, response status code: 422
# request body:
{ "points": -250, "timestamp": "2022-10-31T10:00:00Z", "payer": "AAA" }
# response body
{
    "errors": [
        "Can not create transction result in negative balance."
    ]
}
```
## Get balance
URL: `GET http://localhost:3001/transactions/balance`
URL Params: null
request body: null
Request Sample:
```ruby
# happy path
# response status code: 200
# response body:
[
  {
      "payer": "AAA",
      "points": 0
  },
  {
      "payer": "BBB",
      "points": 250
  }
]
# when there is no transactions, return status code 200 with empty array
[]
```
* curl command
```sh
curl --location --request GET 'http://localhost:3001/transactions/balance' \
--header 'Content-Type: application/json' \
```
## Spend points
URL: `POST http://localhost:3001/transactions/balance`
URL Params: null
Request Body: { "points": 50(int) }
Request Sample:
```ruby
# happy path, response status code: 201
# request body:
{ "points": 250 }
# response body:
[
    {
        "payer": "BBB",
        "points": 200
    },
    {
        "payer": "AAA",
        "points": 50
    }
]
# error sample, response status code: 422
# request body:
{ "points": 250 }
# response body
{
    "errors": [
        "Not enough points"
    ]
}
# error sample, response status code: 422
# request body:
{ "points": 250.0 }
# response body
{
    "errors": [
        "Points must be a positive integer"
    ]
}
```
* curl command
```sh
curl --location --request POST 'http://localhost:3001/transactions/spend' \
--header 'Content-Type: application/json' \
--data-raw '{ "points": 250 }'
```
