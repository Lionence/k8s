# Install

cd demo/redis/chart
helm repo add dandydev https://dandydeveloper.github.io/charts
helm dep update
helm -n demo install redis .

# Access with redis-cli
kubectl -n demo exec -it redis-redis-ha-server-0 -- /usr/local/bin/redis-cli -a "R3d1sD4n1"
