# syntax=docker/dockerfile:1.6

ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG TAG=python-3.12.10
ARG BASE_IMAGE=$REGISTRY/$OWNER/minimal-notebook:$TAG
FROM $BASE_IMAGE

LABEL maintainer="EODC GmbH <support@eodc.eu>"

# Safer shell
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root

# System deps
RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
      s3fs \
      s3cmd \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Use mamba if available (provided by jupyter/minimal-notebook) for speed
# Install heavy scientific stack via conda-forge to avoid pip ABI issues
RUN mamba install -y -n base -c conda-forge \
      jupyterlab \
      ipywidgets \
      bokeh \
      hvplot \
      numba \
      scipy \
      rioxarray \
      dask-labextension \
      pystac-client \
      odc-stac \
      # jupyter-fs is available on conda-forge; prefer conda if you can:
      jupyter-fs \
 && mamba clean -afy

# If some packages are pip-only, install them as the notebook user with --no-deps
# to avoid clobbering conda's solver. We'll switch user first.
USER $NB_UID

# Pip-only installs (pin versions as needed). Avoid --upgrade for reproducibility.
RUN pip install --no-cache-dir \
      rich \
      eodc-connect

# Copy server config as root (system-wide location), then fix ownership
USER root
COPY jupyterlab/jupyter_server_config.json /etc/jupyter/jupyter_server_config.json
# Ensure permissions on conda and home remain friendly to the notebook user
RUN fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

# Switch back to the notebook user
USER $NB_UID