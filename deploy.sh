# Usage:
#   ./deploy.sh production
#   ./deploy.sh dev

if [ -n "$*" ]; then
  env=$*
else
  env=dev
fi

echo "Deploying \033[1;31m$env\033[0m from branch \033[1;33m$(git branch | sed -n '/\* /s///p')\033[0m..."

# build enterprise.go
echo "Building enterprise seeds..."
GOOS=linux GOARCH=amd64 go build -o db/seeds/enterprise db/seeds/enterprise.go

# build seeds.go
echo "Building main seeds..."
GOOS=linux GOARCH=amd64 go build -o db/seeds/main db/seeds/main.go

go run main.go --compile-qor-templates

echo "Deploying..."
harp -s $env -log deploy

# please make sure you can run `ssh deployer@influxdb.theplant-dev.com`, or contact sa@theplant.jp
influxdb_table=$(git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p')
user=$(git config user.name || whoami)
checksum=$(git rev-parse --short HEAD | tr -d '\n')
ssh deployer@influxdb.theplant-dev.com -- /home/de
