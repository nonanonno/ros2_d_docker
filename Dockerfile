ARG base_image="ubuntu:20.04"
FROM ${base_image}

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
    software-properties-common \
    xsel \
    xdg-user-dirs \
    git-lfs \
    python3-pip \
    python3-setuptools \
    curl \
    gnupg2 \
    lsb-release \
    libclang-10-dev \
    clang-10 \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 1

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
RUN locale

# install python tools
RUN python3 -m pip install -U \
    wheel \
    setuptools \
    pylint \
    autopep8

# install ros2
ARG ros_distro="foxy"
ENV ROS_DISTRO ${ros_distro}

RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list' && \
    apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-desktop \
    ros-${ROS_DISTRO}-ros2bag \
    ros-${ROS_DISTRO}-rosbag2-storage-default-plugins \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-argcomplete \
    python3-vcstool \
    g++ \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    && \
    rosdep init

# user config
ARG username="developer"
ARG user_id="1000"
ENV USERNAME ${username}
ENV USER_ID ${user_id}
ENV HOME /home/${USERNAME}

RUN useradd -d ${HOME} -u ${USER_ID} -m ${USERNAME} -s /bin/bash && \
    echo "${USERNAME}:${USERNAME}" | chpasswd && \
    echo "%${USERNAME}    ALL=(ALL)   NOPASSWD:    ALL" >> /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}


USER ${USERNAME}
RUN rosdep update

# install dlang
ARG dlang_version="dmd-2.094.0"

RUN curl -fsS https://dlang.org/install.sh | bash -s ${dlang_version}

# env
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ${HOME}/.bashrc && \
    echo "source ${HOME}/dlang/${dlang_version}/activate" >> ${HOME}/.bashrc && \
    echo "export TERM=xterm-256color" >> ${HOME}/.bashrc && \
    echo "export PS1=\"\[\033[01;32m\]\u@\h:\[\033[01;34m\]\w\[\033[00m\] (ros-${ROS_DISTRO}) (${dlang_version})\n\$ \"" >>  ${HOME}/.bashrc

WORKDIR ${HOME}
SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bin/bash"]