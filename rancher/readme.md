# How to install rancher on VMs with Docker

## PreReq
sudo snap install docker

## Install
sudo docker run -d --name rancher-server \
    -v ${PWD}/volume:/var/lib/rancher \
    --restart=unless-stopped \
    -p 80:80 -p 443:443 \
    --privileged rancher/rancher:v2.7.5 \
    --acme-domain k8s.devopsdani.com

## Register new nodes
```
sudo docker run -d --privileged --name rancher-agent\
    --restart=unless-stopped --net=host \
    -v /etc/kubernetes:/etc/kubernetes \
    -v /var/run:/var/run\
    rancher/rancher-agent:v2.7.5 \
    --server YOUR_SERVER \
    --token TOKEN \
    --address ADDRESS_optional \
    --etcd --controlplane --worker
```

## Register nodes from on-premise network

Follow these steps to set up Point-to-Site VPN tunnel
>**Note: Basic SKU won't work**<br>
https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal

For ipsec apply these settings (/etc/ipsec.conf)
```
conn azure
    keyexchange=ikev2
    type=tunnel
    leftfirewall=yes
    left=%any
    leftauth=eap-tls
    leftid=%<HOSTNAME>
    right=<VPN_NAME>
    rightid=%<VPN_NAME>
    rightsubnet=0.0.0.0/0
    leftsourceip=%config
    auto=add
    esp=aes256gcm16-sha256-ecp384!
```