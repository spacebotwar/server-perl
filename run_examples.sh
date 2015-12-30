docker run --link sbw-redis --link sbw-beanstalk  --rm -it  -v ${PWD}/code:/opt/code my-perl /bin/bash
