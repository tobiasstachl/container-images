ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG TAG=python-3.12.10
ARG BASE_IMAGE=$REGISTRY/$OWNER/minimal-notebook:$TAG
FROM $BASE_IMAGE

LABEL maintainer="EODC GmbH <support@eodc.eu>"

# Safer shell
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
      s3fs \
      s3cmd \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Conda/ Mamba install: pin a compact, compatible HoloViz stack for Py 3.12 + Bokeh 3.4
RUN mamba install -y -n base -c conda-forge \
      python=3.12 \
      jupyterlab \
      ipywidgets \
      bokeh=3.4.* \
      panel=1.4.* \
      holoviews=1.21.* \
      hvplot=0.12.* \
      xarray>=2024.1 \
      rioxarray \
      numba \
      scipy \
      jupyter_bokeh \
      pystac-client \
      odc-stac \
      jupyter-fs \
  && mamba clean -afy

# Environment knobs to keep pip from leaving caches/pyc
ENV PIP_NO_CACHE_DIR=1
ENV PYTHONDONTWRITEBYTECODE=1

# Switch to notebook user for pip-only packages
USER $NB_UID

RUN pip install --no-cache-dir --no-compile \
      rich \
      eodc-connect

# Server config and permissions
USER root
COPY jupyterlab/jupyter_server_config.json /etc/jupyter/jupyter_server_config.json
RUN fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

# Back to the notebook user
USER $NB_UID
