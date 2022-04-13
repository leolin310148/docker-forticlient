#!/usr/bin/env bash

docker build -t docker.puni.tw/forticlient .

docker push docker.puni.tw/forticlient
