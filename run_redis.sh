docker run -d -v ${PWD}/redis.conf:/usr/local/etc/redis/redis.conf -p 6379:6379 --name sbw-redis redis redis-server

