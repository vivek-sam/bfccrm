#!/bin/bash

cd alpine-base
./build.sh

cd ../alpine-apache-php7
./build.sh

cd ../alpine-maria
./build.sh

cd ../churchcrm
./build.sh