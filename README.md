# lua-utopia
An example based on nginx-http-lua-module. 

Usage
===========
```
1. copy nginx.conf
2. copy utopia
```

Test
=============
```
1. run nginx:
> ./objs/nginx

2. upload config
> curl -X POST -d@conf.json http://127.1:8000/config

3. curl test
> curl http://127.1:80
```
