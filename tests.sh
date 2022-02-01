set -e

#install dep

pip3 install --user pylint bottle

pylint ./web/server.py
docker build -t anantac/lb ./lb
docker build -t anantac/bottle ./web
/usr/local/bin/docker-compose up -d
response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://localhost/ping)

if [[ $response -ne 200 ]];then
  echo 'health check failed'
  exit 1
else
  echo hurrah! health check passed. response code is - $response
fi
