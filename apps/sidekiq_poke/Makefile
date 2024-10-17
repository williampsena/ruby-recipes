up:
	docker compose --profile=db up -d

down:
	docker compose --profile=all down --rmi local -v

run-local:
	rackup -p 4000

run-sideki-local:
	bundle exec sidekiq -r ./sidekiq.rb

run:
	docker compose --profile=app up -d --build

test:
	ENV=test rspec

clean-images:
	rm -r public/poke_images/* 

format:
	rubocop -A

requests:
	bash scripts/requests.sh
