FROM nvcr.io/nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        build-essential \
        cmake \
        git \
        tzdata \
        wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean

# Install Miniconda package manager.
RUN wget -q -P /tmp \
  https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm /tmp/Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/opt/conda/bin:$PATH"
RUN conda install -y python=3.10 pip cudatoolkit=11.6\
    && conda clean --all --force-pkgs-dirs --yes
WORKDIR /app
RUN git clone https://github.com/nrbennet/dl_binder_design.git && \
    git clone https://github.com/RosettaCommons/RFdiffusion.git && \
    git clone https://github.com/Wangchentong/rfd_mpnn_af2_env.git
# Setup RFdiffusion env
RUN pip install --no-cache-dir \
    torch==1.13.0+cu116 --extra-index-url https://download.pytorch.org/whl/cu116 \
    e3nn \
    hydra-core \
    pyrsistent \
    numpy==1.24.3
RUN conda install -y dgl-cuda11.1 -c defaults -c dglteam -c pytorch
RUN cd /app/RFdiffusion/env/SE3Transformer/ && python setup.py install
RUN cd /app/RFdiffusion/ && pip install -e .
RUN mkdir models && cd models && wget http://files.ipd.uw.edu/pub/RFdiffusion/e29311f6f1bf1af907f9ef9f44b8328b/Complex_base_ckpt.pt
# Setup ProteinMPNN env
RUN conda install -y pyrosetta -c https://conda.graylab.jhu.edu
RUN cd dl_binder_design/mpnn_fr/ && git clone https://github.com/dauparas/ProteinMPNN.git
# Setup Alphafold2 env
RUN conda install -y ml-collections ml_dtypes tensorflow mock -c pytorch -c nvidia -c conda-forge -c defaults
RUN pip install --no-cache-dir dm-haiku==0.0.4 dm-tree==0.1.6 jax==0.4.13 jaxlib==0.4.13+cuda11.cudnn86 biopython==1.79 -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
RUN mkdir -p dl_binder_design/model_weights/params \ 
    && cd dl_binder_design/model_weights/params \ 
    && wget https://storage.googleapis.com/alphafold/alphafold_params_2022-12-06.tar \ 
    && tar --extract --verbose --file=alphafold_params_2022-12-06.tar
CMD ["/bin/bash"]
