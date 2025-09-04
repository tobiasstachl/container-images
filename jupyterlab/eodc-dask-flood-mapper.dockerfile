# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG TAG=python-3.11.10
ARG BASE_IMAGE=$REGISTRY/$OWNER/minimal-notebook:$TAG
FROM $BASE_IMAGE

LABEL maintainer="EODC Gmbh <support@eodc.eu>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update --yes && \
  apt-get install --yes --no-install-recommends \
  # s3 support
  s3fs \
  s3cmd && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade \
  pexpect==4.9.0 \
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
  geoviews \
  eodc-connect

RUN jupyter lab build --minimize=False -y

RUN pip install --no-cache-dir --upgrade jupyter-fs
COPY jupyterlab/jupyter_server_config.json /etc/jupyter/jupyter_server_config.json

USER ${NB_UID}