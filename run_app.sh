docker run --link sbw-redis --link sbw-beanstalk --link sbw-mysql --rm -it  --name=sbw-server-perl -p 5000:4000 -p 8090:8080 -v ${PWD}/code:/opt/code my-perl /bin/bash
