FROM continuumio/miniconda3:25.3.1-1

ENV HOME=/home/jovyan \
    PATH=/opt/conda/bin:$PATH

USER root

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    curl git less vim-tiny nano-tiny && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR $HOME

COPY eodc-dask-flood-mapper-environment.yml /environment.yml

RUN conda install mamba -n base -c conda-forge && \
    mamba env update -n base -f /environment.yml && \
    mamba clean --all -f -y && \
    rm -rf /environment.yml

USER root

EXPOSE 8888
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]


#RUN curl -L https://raw.githubusercontent.com/interTwin-eu/dask-flood-mapper/refs/heads/workshop-f/notebooks/workshop.ipynb \
#    -o /home/jovyan/workshop.ipynb
