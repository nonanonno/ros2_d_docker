#!/bin/bash
cd `dirname $0`

# base_image=nvidia/cuda:11.0-devel-ubuntu20.04
base_image=ubuntu:20.04
ros_distro=foxy
user_id=`id -u`
username=developer
dlang_version=dmd-2.094.0

docker build . --build-arg username=$username \
               --build-arg user_id=$user_id \
               --build-arg base_image=$base_image \
               --build-arg ros_distro=$ros_distro \
               --build-arg dlang_version=$dlang_version \
               --file Dockerfile \
               -t my/ros2:$ros_distro