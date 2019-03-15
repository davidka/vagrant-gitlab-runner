#!/usr/bin/env bash

echo "Build custom docker-compose image..."


cat <<EOT >> Dockerfile
FROM docker:latest
RUN apk add --no-cache python py2-pip
RUN pip install --no-cache-dir docker-compose
EOT

cat Dockerfile

docker build -t $5 .

echo "Gitlab CI Runner configuration..."

echo "Create gitlab-runner working directory..."
mkdir -p /gitlab-runner

echo "Download gitlab-ci-runner..."
curl -o /usr/local/bin/gitlab-runner -L https://gitlab-runner-downloads.s3.amazonaws.com/$1/binaries/gitlab-runner-linux-amd64
chmod +x /usr/local/bin/gitlab-runner

echo "Register  gitlab-runner..."
/usr/local/bin/gitlab-runner install --user=root --working-directory=/gitlab-runner
/usr/local/bin/gitlab-runner start
/usr/local/bin/gitlab-runner register --non-interactive --name $2 --url $3 --registration-token $4 \
              --executor docker --docker-image $5 --tag-list $6 --docker-pull-policy if-not-present \
              --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
