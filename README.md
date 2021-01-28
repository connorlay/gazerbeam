# Gazerbeam

A toy GitHub repository stargazer tracker built with Elixir & Phoenix

Made with :heart: by Connor Lay

## Requirements

- Docker
- Docker Compose
- Elixir
- Curl (optional)

## Setup & Development

1. Clone this repository
```sh
git clone git@github.com:connorlay/gazerbeam.git
```

2. Setup the development environment
```sh
mix setup
```

3. (Optional) Set your [GitHub personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) so Gazerbeam can make authenticated API requests
```sh
export GITHUB_TOKEN=<YOUR_PERSONAL_ACCESS_TOKEN>
```
Note: Gazerbeam can make unauthenticated requests, but these will have a much lower rate-limit

4. Start the Phoenix server
```sh
mix phx.server
```

5. (Optional) Run the test suite
```sh
mix test
```

6. (Optional) Run the code linter
```sh
mix credo
```

## Usage

1. Add a GitHub repository to Gazerbeam
```sh
curl -X POST 'localhost:4000/api/repositories' -H 'content-type: application/json' --data '{"owner": "pop-os", "name": "shell"}'

{
  "data": {
    "github_id": 221831081,
    "id": 1,
    "name": "shell",
    "owner": "pop-os",
    "synced_at": null,
    "url": "https://github.com/pop-os/shell"
  }
}
```

2. Sync all stargazers for a repository
```sh
mix gazerbeam sync_one 1
```

3. List all tracked repositories
```sh
curl -X GET 'localhost:4000/api/repositories'

{
  "data": [
    {
      "github_id": 221831081,
      "id": 1,
      "name": "shell",
      "owner": "pop-os",
      "synced_at": "2021-01-31T21:20:37",
      "url": "https://github.com/pop-os/shell"
    }
  ]
}
```

4. Get all stargazers for a repository
```sh
curl -X GET 'localhost:4000/api/repositories/REPOSITORY_ID/stargazers'

{
  "data": [
    # ...
    {
      "github_user_id": 67544305,
      "id": 2291,
      "is_deleted": false,
      "name": "z00kiee",
      "starred_at": "2021-01-30T13:20:16",
      "url": "https://github.com/z00kiee"
    },
    {
      "github_user_id": 398828,
      "id": 2292,
      "is_deleted": false,
      "name": "funvit",
      "starred_at": "2021-01-31T18:50:30",
      "url": "https://github.com/funvit"
    },
    {
      "github_user_id": 19996318,
      "id": 2293,
      "is_deleted": false,
      "name": "leonhfr",
      "starred_at": "2021-01-31T19:35:29",
      "url": "https://github.com/leonhfr"
    }
    # ...
  ]
}
```

5. Get all stargazers for a repository within a date range (YYYY-MM-DD)
```sh
curl -X GET 'localhost:4000/api/repositories/1/stargazers?start_date=2020-01-01&end_date=2021-01-01'

{
  "data": [
    # ...
    {
      "github_user_id": 76754624,
      "id": 2178,
      "is_deleted": false,
      "name": "wren42",
      "starred_at": "2020-12-31T00:57:45",
      "url": "https://github.com/wren42"
    },
    {
      "github_user_id": 2582004,
      "id": 2179,
      "is_deleted": false,
      "name": "itbj",
      "starred_at": "2020-12-31T05:25:21",
      "url": "https://github.com/itbj"
    },
    {
      "github_user_id": 46822325,
      "id": 2180,
      "is_deleted": false,
      "name": "tajpouria",
      "starred_at": "2020-12-31T15:59:20",
      "url": "https://github.com/tajpouria"
    }
  ]
}
```

## Mix Tasks

- `mix setup`: bootstraps the project
- `mix phx.server`: starts the Phoenix server
- `mix ecto.migrate`: runs Ecto migrations
- `mix test`: runs ExUnit tests
- `mix credo`: runs Credo linter
- `mix docker_compose up`: starts Docker Compose
- `mix docker_compose down`: stop Docker Compose
- `mix docker_compose drop`: resets Docker Compose
- `mix gazerbeam get_rate_limit`: returns the current GitHub API rate-limit
- `mix gazerbeam sync_one <repository_id>`: sync stargazers for a tracked repository
- `mix gazerbeam sync_all`: sync all stargazers for all tracked repositories
