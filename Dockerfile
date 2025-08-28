# pull official base image
# tested successfully with version 24.5.11
FROM continuumio/miniconda3:25.3.1-1

# add the user 
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}
ENV PATH="$HOME/idaes-pse/bin:$PATH"

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# copy contents to docker image 
COPY environment.yml ${HOME}
COPY hda_flowsheet_solution.ipynb ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

# set working directory
WORKDIR ${HOME}
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
RUN conda env create -p ${HOME}/idaes-pse -f environment.yml
RUN conda init bash
SHELL ["/bin/bash", "--login", "-c"]
RUN conda init && conda activate ${HOME}/idaes-pse && python -m ipykernel install --user --name=idaes-pse --display-name="Python (idaes-pse)"
ENTRYPOINT []

