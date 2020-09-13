#!/usr/bin/env sh

echo "Removing api container if it exists..."
sudo docker container rm -f api || true
echo "Removing network test-net if it exists..."
sudo docker network rm test-net || true

echo "Deploying app ($registry:$BUILD_NUMBER)..."
sudo docker network create test-net

sudo docker container run -d --name api --net test-net $registry:$BUILD_NUMBER

#logic to wait for the api component to be ready on port 3000

read -d '' wait_for << EOF
echo "Waiting for API to listen on port 3000..."
while ! nc -z api 3000; do
	sleep 0.1 # wait for 1/10 of the second before check again
	printf "."
done
echo "API ready on port 3000!"
EOF

sudo docker container run --rm --net test-net node:12.10-alpine sh -c "$wait_for"

echo "Smoke tests..."
sudo docker container run --name tester --rm --net test-net swtest/node-docker sh -c "curl api:3000"





