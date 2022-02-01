# Simple Nginx Load Balancer

## Prerequisite
  Have host with docker and docker-compose installed and access to Internet ( If you want to pull images from docker hub instead of building using the Dockerfiles)

## Setup 
The docker-compose.yaml has 3 servers, 2 web and 1 load balancer defined.
The web apps run a simple python bottle app that has two routes
  - /hello ; returns Hello + hostname
  - /ping; returns 200 status


## Health checks
NGIX health checks are not available in free version :roll_eyes:

http://nginx.org/en/docs/http/ngx_http_upstream_hc_module.html


# Default Bottle app return codes. 

  Nginx forwards the return code from the bottle app. This can be customized if we want to send custom responses.
  - 200 - on valid route
  - 404 - when there is no route
  - 503 - when the app fails to respond to route. Hard to reproduce
  
  We can also customize the responses and send a different return codes depending on route logic/action

# How to run

github actions scripts to verify the [ app ]( https://github.com/ac427/lb-test/blob/main/tests.sh#L8#L10)

Bring all the containers up using docker-compose

```
[abc@foo 15:48:32 - new_relic]$docker-compose up
Starting new_relic_server1_1 ... done
Starting new_relic_server2_1 ... done
Recreating new_relic_lb_1    ... done
Attaching to new_relic_server1_1, new_relic_server2_1, new_relic_lb_1
lb_1       | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
lb_1       | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
lb_1       | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
lb_1       | 10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
lb_1       | 10-listen-on-ipv6-by-default.sh: info: /etc/nginx/conf.d/default.conf differs from the packaged version
lb_1       | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
lb_1       | /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
lb_1       | /docker-entrypoint.sh: Configuration complete; ready for start up
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: using the "epoll" event method
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: nginx/1.21.4
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6) 
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: OS: Linux 5.15.16-100.fc34.x86_64
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: start worker processes
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: start worker process 31
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: start worker process 32
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: start worker process 33
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: start worker process 34
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: start worker process 35
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: start worker process 36
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: start worker process 37
lb_1       | 2022/02/01 20:48:35 [notice] 1#1: start worker process 38
```

In a new shell verify the images/ports. docker compose logs will also failures if something goes wrong.

```
[abc@foo 15:49:44 - new_relic]$docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED              STATUS              PORTS                                       NAMES
7730a19a7a4a   anantac/lb       "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:80->80/tcp, :::80->80/tcp           new_relic_lb_1
8b75a0fa01f4   anantac/bottle   "/home/app/server.py"    About an hour ago    Up About a minute   0.0.0.0:9001->5000/tcp, :::9001->5000/tcp   new_relic_server1_1
6e01909dd278   anantac/bottle   "/home/app/server.py"    About an hour ago    Up About a minute   0.0.0.0:9002->5000/tcp, :::9002->5000/tcp   new_relic_server2_1
[abc@foo 15:49:46 - new_relic]$
```

# Test/Verify

check the running containers

```

[abc@foo 15:49:44 - new_relic]$docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED              STATUS              PORTS                                       NAMES
7730a19a7a4a   anantac/lb       "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:80->80/tcp, :::80->80/tcp           new_relic_lb_1
8b75a0fa01f4   anantac/bottle   "/home/app/server.py"    About an hour ago    Up About a minute   0.0.0.0:9001->5000/tcp, :::9001->5000/tcp   new_relic_server1_1
6e01909dd278   anantac/bottle   "/home/app/server.py"    About an hour ago    Up About a minute   0.0.0.0:9002->5000/tcp, :::9002->5000/tcp   new_relic_server2_1

```

Test route

```
[abc@foo 15:49:46 - new_relic]$curl http://localhost/hello
Hello World! from 8b75a0fa01f4
[abc@foo 15:51:09 - new_relic]$curl http://localhost/hello
Hello World! from 6e01909dd278
```
Test healthcheck end point

```
[abc@foo 15:51:11 - new_relic]$curl -v http://localhost/ping
*   Trying ::1:80...
* Connected to localhost (::1) port 80 (#0)
> GET /ping HTTP/1.1
> Host: localhost
> User-Agent: curl/7.76.1
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Server: nginx/1.21.4
< Date: Tue, 01 Feb 2022 20:51:18 GMT
< Content-Type: text/html; charset=UTF-8
< Content-Length: 0
< Connection: keep-alive
< 
* Connection #0 to host localhost left intact
```

Check non existing route

```
[abc@foo 15:51:18 - new_relic]$curl http://localhost/failme

    <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
    <html>
        <head>
            <title>Error: 404 Not Found</title>
            <style type="text/css">
              html {background-color: #eee; font-family: sans;}
              body {background-color: #fff; border: 1px solid #ddd;
                    padding: 15px; margin: 15px;}
              pre {background-color: #eee; border: 1px solid #ddd; padding: 5px;}
            </style>
        </head>
        <body>
            <h1>Error: 404 Not Found</h1>
            <p>Sorry, the requested URL <tt>&#039;http://lb/failme&#039;</tt>
               caused an error:</p>
            <pre>Not found: &#039;/failme&#039;</pre>
        </body>
    </html>

```

Stop one of the web container and run curl. 
It took 30s to respond since the default is round robin and we stopped the next in the line ( 3*10 in lb.conf)


```
[abc@foo 15:51:27 - new_relic]$docker stop 8b75a0fa01f4
8b75a0fa01f4
[abc@foo 15:51:59 - new_relic]$curl http://localhost/hello
Hello World! from 6e01909dd278
[abc@foo 15:52:24 - new_relic]$
[abc@foo 15:52:25 - new_relic]$curl http://localhost/hello
Hello World! from 6e01909dd278

```
Kill the second container

```
Hello World! from 6e01909dd278[abc@foo 15:54:07 - new_relic]$docker stop 6e01909dd278
6e01909dd278
```

Nginx returns 502 as there is no reachable network.

```
[abc@foo 15:55:16 - new_relic]$curl http://localhost/hello
<html>
<head><title>502 Bad Gateway</title></head>
<body>
<center><h1>502 Bad Gateway</h1></center>
<hr><center>nginx/1.21.4</center>
</body>
</html>
[abc@foo 15:55:40 - new_relic]$

```
