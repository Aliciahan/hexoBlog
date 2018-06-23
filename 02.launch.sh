#!/bin/bash

kill -9 $(ps aux | grep hexo | grep -v grep | awk '{print $2}')
nohup hexo server > ./err.log 2>&1 &
