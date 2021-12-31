FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# 2: America; 151: vancouver
RUN set -ex && apt update -y && apt install vim -y && apt install sudo -y \
    && echo '2' | echo '151' | apt-get install software-properties-common -y \
    && apt install net-tools iputils-ping wget curl git unzip -y

# Dependencies for glvnd and X11.
RUN apt update && apt-get update \
    && apt install -y -qq --no-install-recommends \
    libxext6 libx11-6 libglvnd0 libgl1 libglx0 libegl1 \
    freeglut3-dev \
    && rm -rf /var/lib/apt/lists/*

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute

RUN apt-get update -qq && \
    apt-get upgrade -y  > /dev/null 2>&1 && \
    apt-get install wget gcc make zlib1g-dev libxrender1 -y -qq > /dev/null 2>&1

# conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.10.3-Linux-x86_64.sh \
    && bash Miniconda3-py37_4.10.3-Linux-x86_64.sh -b

ENV PATH=/root/miniconda3/bin:${PATH}
RUN conda init bash

# Dependencies
RUN apt update && apt-get update \
    && apt install -y libgl1-mesa-dev libglew-dev 

# DF-VO
RUN cd /root && git clone https://github.com/HardysJin/DF-VO.git

WORKDIR /root/DF-VO

# conda env
RUN cd envs && conda env create -f requirement.yml
RUN conda env list && /root/miniconda3/envs/dfvo/bin/pip install gdown \
    && /root/miniconda3/envs/dfvo/bin/gdown --id 1HgIJUHgiW5ZCYgUsQfpIu-SSHQgUgBqw -O model_zoo.zip
RUN unzip model_zoo.zip && rm model_zoo.zip

ENV PYTHONPATH=$PYTHONPATH:/root/DF-VO/