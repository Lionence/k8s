# Custom solution for wildcard management (OLD, DEPRECATED)

This solution should not be used in production environments!
It was made when devopsdani.com DNS zone was managed under godaddy back in 2020.
cert-manager didn't work at that time, so I made my custom solution for our dev k8s cluster.

## Install
```
docker build -t <your_private_repo>:latest ./build/
helm install acme-certjob chart/
```