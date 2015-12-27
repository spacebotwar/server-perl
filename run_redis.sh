#docker run -v ${PWD}/redis.conf:/usr/local/etc/redis/redis.conf -p 6379:6379 --name sbw-redis -d redis redis-server /usr/local/etc/redis/redis.conf
docker run --rm -it -v ${PWD}/redis.conf:/usr/local/etc/redis/redis.conf -p 6379:6379 --name sbw-redis redis redis-server

