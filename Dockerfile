# pull official base image
# tested successfully with version 24.5.11
# FROM continuumio/miniconda3:25.3.1-1
FROM ubuntu:22.04

# Install apt packages
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    git \
    libgfortran5 \
    liblapack3 \
    liblapack-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# add the user 
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# install miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${HOME}/conda && \
    rm /tmp/miniconda.sh
ENV PATH=${HOME}/conda/bin:$PATH
# copy contents to docker image 
COPY environment.yml ${HOME}
COPY hda_flowsheet_solution.ipynb ${HOME}
COPY ipopt_test.py ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

# set working directory
WORKDIR ${HOME}
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
RUN conda env create -f environment.yml --prefix ${HOME}/idaes-pse
ENV PATH="$HOME/idaes-pse/bin:$PATH"

# RUN conda init bash
# SHELL ["/bin/bash", "--login", "-c"]
RUN echo "source activate idaes-pse" > ~/.bashrc
RUN conda run -p ${HOME}/idaes-pse python -m ipykernel install --user --name=idaes-pse --display-name="Python (idaes-pse)"
RUN conda run -p ${HOME}/idaes-pse idaes get-extensions --to /home/jovyan/idaes-pse/bin
RUN cp -r ${HOME}/idaes-pse/lib/python3.12/site-packages/idaes_examples/notebooks/docs/tut ${HOME}/
ENTRYPOINT []
