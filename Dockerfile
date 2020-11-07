FROM nvidia/cuda:10.2-cudnn7-devel

ARG username="developer"
ARG user_id="1000"
ARG ros_distro="dashing"
ARG dlang_version="dmd-2.093.1"

# user config
ENV USERNAME ${username}
ENV USER_ID ${user_id}
ENV HOME /home/${USERNAME}

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    less \
    emacs \
    tmux \
    bash-completion \
    command-not-found \
    software-properties-common \
    xsel \
    xdg-user-dirs \
    git-lfs \
    python3-pip \
    python3-setuptools \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# locale
RUN apt-get update && apt-get install -y --no-install-recommends \
    language-pack-en \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# add user
RUN useradd -d ${HOME} -u ${USER_ID} -m ${USERNAME} -s /bin/bash && \
    echo "${USERNAME}:${USERNAME}" | chpasswd && \
    echo "%${USERNAME}    ALL=(ALL)   NOPASSWD:    ALL" >> /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# install ros
ENV ROS_DISTRO ${ros_distro}

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    lsb-release \
    && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    sh -c 'echo "deb http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list' && \
    apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-desktop \
    ros-${ROS_DISTRO}-ros2bag \
    ros-${ROS_DISTRO}-rosbag2-storage-default-plugins \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-argcomplete \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rosdep init

# install python tools
RUN python3 -m pip install -U \
    wheel \
    setuptools \
    pylint \
    autopep8


USER ${USERNAME}
RUN rosdep update

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ${HOME}/.bashrc 

# install dlang
RUN curl -fsS https://dlang.org/install.sh | bash -s ${dlang_version}

RUN echo "source ~/dlang/${dlang_version}/activate" >> ${HOME}/.bashrc

WORKDIR ${HOME}
SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bin/bash"]