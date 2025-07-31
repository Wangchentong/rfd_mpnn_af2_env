FROM nvcr.io/nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        build-essential \
        cmake \
        git \
        tzdata \
        wget \
        openssh-server \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y && apt-get clean

RUN mkdir /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

RUN wget -q -P /tmp https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh && \
    bash /tmp/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh -b -p /opt/conda && \
    rm /tmp/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh
ENV PATH="/opt/conda/bin:$PATH"

RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
    conda config --set channel_priority flexible && \
    conda config --set show_channel_urls yes && \
    conda install -n base -c conda-forge mamba -y

ENV PATH="/opt/conda/bin:$PATH"
RUN echo 'export PATH="/opt/conda/bin:$PATH"' >> ~/.bashrc
RUN mamba install -y python=3.10 -c conda-forge && \
    mamba install -y pip && \
    conda clean --all --force-pkgs-dirs --yes
WORKDIR /app
RUN git clone https://github.com/nrbennet/dl_binder_design.git && \
    git clone https://github.com/RosettaCommons/RFdiffusion.git && \
    git clone https://github.com/Wangchentong/rfd_mpnn_af2_env.git
# Setup RFdiffusion env
ENV PIP_TIMEOUT=1000
ENV PIP_RETRIES=10
RUN pip install --no-cache-dir numpy==1.24.3 pyrsistent hydra-core
RUN pip install --no-cache-dir torch==1.13.0+cu116 --extra-index-url https://download.pytorch.org/whl/cu116
RUN pip install --no-cache-dir e3nn
RUN mamba install -y dgl-cuda11.6 -c dglteam
RUN cd /app/RFdiffusion/env/SE3Transformer/ && python setup.py install
RUN cd /app/RFdiffusion/ && pip install -e .
RUN cd /app/RFdiffusion/ && mkdir models && cd models && wget http://files.ipd.uw.edu/pub/RFdiffusion/e29311f6f1bf1af907f9ef9f44b8328b/Complex_base_ckpt.pt && wget http://files.ipd.uw.edu/pub/RFdiffusion/60f09a193fb5e5ccdc4980417708dbab/Complex_Fold_base_ckpt.pt
RUN cd /app/RFdiffusion/examples/ && tar -xvf ppi_scaffolds_subset.tar.gz
# Setup ProteinMPNN env
RUN mamba install -y pyrosetta -c https://conda.graylab.jhu.edu
RUN cd dl_binder_design/mpnn_fr/ && git clone https://github.com/dauparas/ProteinMPNN.git
# Setup Alphafold2 env
RUN mamba install -y ml-collections ml_dtypes tensorflow mock -c conda-forge
RUN pip install --no-cache-dir dm-haiku==0.0.4 dm-tree==0.1.6 jax==0.4.13 jaxlib==0.4.13+cuda11.cudnn86 biopython==1.79 -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
RUN pip install --no-cache-dir scipy==1.15.2
RUN mkdir -p dl_binder_design/af2_initial_guess/model_weights/params && \ 
    cd dl_binder_design/af2_initial_guess/model_weights/params && \ 
    wget https://storage.googleapis.com/alphafold/alphafold_params_2022-12-06.tar && \ 
    tar --extract --verbose --file=alphafold_params_2022-12-06.tar
CMD ["/bin/bash"]
