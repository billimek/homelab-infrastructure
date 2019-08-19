Configure haproxy to use the new k8s nodes with the following in the configuration:

```haproxy
frontend k8s-ha-api
 bind 10.0.7.30:6443
 mode tcp
 option tcplog
 default_backend k8s-ha-api

backend k8s-ha-api
 mode tcp
 option tcp-check
 balance roundrobin
 server k8s-a 10.2.0.10:6443 check fall 3 rise 2
 server k8s-b 10.2.0.11:6443 check fall 3 rise 2
 server k8s-c 10.2.0.12:6443 check fall 3 rise 2
```

* 10.0.7.30 (lb-ha) is a VIP that floats between 10.0.7.10 and 10.0.7.16 via keepalived
* 10.2.0.10. 10.2.0.11, 10.2.0.12 are the master nodes where the kube-apiserver runs

Configure haproxy to route http and https to traefik:

```haproxy
frontend https_frontend
    bind 10.0.7.30:443
    option tcplog
    mode tcp
    option clitcpka
    tcp-request inspect-delay 5s
    tcp-request content accept if { req.ssl_hello_type 1 }
    use_backend https_k8s_traefik if { req_ssl_sni -m end .mydomain.com }

backend https_k8s_traefik
    option tcp-check
    balance source
    server     metallb-150 10.2.0.150:443 check

frontend http_frontend
    bind 10.0.7.30:1080
    mode http
    default_backend http_k8s_backend

backend http_k8s_backend
    mode http
    balance source
    server      metallb-150 10.2.0.150:80 check
```

* 10.2.0.150 is the metallb-assigned IP for traefik