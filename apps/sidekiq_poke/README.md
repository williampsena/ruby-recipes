# Intro

This project is a test case that simulates a Sikekiq flow with issues, slow consumers, retries, and other behaviors using tree workers.

# Dependencies

```shell
sudo apt-get install -y imagemagick libmagickwand-dev
bundle install
```

# Pods

Preparing pods dependencies:

## Up

```shell
make up
```

## Down

```shell
make down
```

# How to run?
## With redis non persistent
```shell
make run
docker compose logs -f sidekiq app
```

# With redis persistent
```shell
make run-persistent
docker compose logs -f sidekiq-persistent app-persistent
```

# Send batch over API

```shell
# single requests
curl -X POST http://localhost:4000/pokemon/batch \
  -H "Content-Type: application/json" \
   -d "{\"names\": [\"pikachu\"]}"

# multiple requests
make requests
```

# Monitoring

- [Sidekiq Dash](http://localhost:4000/sidekiq)
- [Sidekiq Dash Persistent](http://localhost:4001/sidekiq)
- [Redis Insight](http://localhost:15540)
> We should include these instances in our testing `redis:16379` and `redis-persistent:16380`. 
