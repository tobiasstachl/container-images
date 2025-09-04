# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG TAG=python-3.12.10
ARG BASE_IMAGE=$REGISTRY/$OWNER/minimal-notebook:$TAG
FROM $BASE_IMAGE

LABEL maintainer="EODC GmbH <support@eodc.eu>"

# Use bash with pipefail for safer scripting
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install system dependencies
RUN apt-get update --yes && \
  apt-get install --yes --no-install-recommends \
  s3fs \
  s3cmd && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir --upgrade \
  jupyterlab_widgets \
  dask-labextension \
  rich \
  hvplot \
  bokeh \
  numba \
  scipy \
  pystac_client \
  odc-stac \
  rioxarray \
  # geoviews \
  # datashader \
  eodc-connect

# Clean JupyterLab build cache and build (if needed)
RUN jupyter lab clean --all

# Install additional extensions
RUN pip install --no-cache-dir --upgrade jupyter-fs

# Copy server config
COPY jupyterlab/jupyter_server_config.json /etc/jupyter/jupyter_server_config.json

# Switch back to notebook user
USER $NB_UID