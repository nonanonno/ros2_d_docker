#!/bin/bash
cd `dirname $0`

ros_distro=foxy
user_id=`id -u`
username=developer
dlang_version=dmd-2.094.0

docker build . --build-arg username=$username \
               --build-arg user_id=$user_id \
               --build-arg ros_distro=$ros_distro \
               --build-arg dlang_version=$dlang_version \
               --file Dockerfile.foxy \
               -t my/ros2:$ros_distro