#!/bin/sh
sudo docker build -t timmy/blog -f Dockerfile .
sudo docker run -it --rm --network host -v $(pwd):/blog timmy/blog
