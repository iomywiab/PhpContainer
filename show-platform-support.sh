#!/bin/bash

for i in `docker images --format {{.ID}}`; do echo $i `docker image inspect $i |grep Os`; done