# StockTrackerApi

[![Elixir Build and Test](https://github.com/dutraleonardo/stock_tracker_api/actions/workflows/test.yml/badge.svg)](https://github.com/dutraleonardo/stock_tracker_api/actions/workflows/test.yml)

[![DEPLOY](https://github.com/dutraleonardo/stock_tracker_api/actions/workflows/deploy.yml/badge.svg)](https://github.com/dutraleonardo/stock_tracker_api/actions/workflows/deploy.yml)

#### How to run:

1. Using docker-compose

1. Install Docker and docker-compose [here](http:/https://docs.docker.com/compose/install//  "here").

2. In the project root, run the following command to up the database and server:

```shell

docker-compose up

```

2. Running without docker-compose

1. Erlang and Elixir (I recommend to use [`asdf`](https://asdf-vm.com/#/) to manage versions on your local enviroment. The versions can be found in [`.tool-versions`](/.tool-versions)).

a. In case of you don't want to use `asdf` you can install Elixir following this [link](http:/https://elixir-lang.org/install.html/ "link" .

2. To start your Phoenix server:

* Install dependencies with `mix deps.get`

* Create and migrate your database with `mix ecto.setup`

* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

#### How it works (start monitoring a stock ticker):
* Send a **POST** request to /track with the following body:
    ```json
    {
    	"stock_ticker": "TSLA"
    }
    ```
* This request trigger a GenServer called MonitorServer that execute a request to Alpha Vantage API every 10 minutes to get the last stock quote and save it.
* In parallel, another GenServer called RateLimiterServer that checks if request limit will not be extrapolated. Alpha Vantage API has limits by minute and day.
* If you want to search for data you cand send a **GET** request to /status endpoint with the following parameters:
    ```
    start: YYYY-MM-DD
    end: YYYY-MM-DD
    stock_ticker: TSLA
    min_volume: 30880589
    ```

#### Resources:
* Take a look on **postman**, there is a postman collection.

## Live API URL:
[Stock Tracker API](https://finiam-stock-tracker-api.herokuapp.com/)
&&
[Stock Tracker API Health Check](https://finiam-stock-tracker-api.herokuapp.com/api/health)

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
