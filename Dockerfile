# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/debian/Dockerfile
# https://conda.io/projects/conda/en/latest/commands.html#conda-vs-pip-vs-virtualenv-commands
# 
# docker build --rm=true --no-cache=true -t guitarmind/deepml-cpu -f ./Dockerfile .
# docker run --rm -p 8888:8888 -p 6006:6006 --name deepml-cpu -it guitarmind/deepml-cpu bash
# 

FROM gpuci/miniconda-cuda:11.2-devel-ubuntu20.04

LABEL MAINTAINER="Roscoe Chen"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    # Disabling SSL verification
    SSL_NO_VERIFY=1 \
    PATH=/opt/conda/bin:$PATH \
    PYTHONDONTWRITEBYTECODE=true \
    TZ=Asia/Taipei

EXPOSE 8888 6006 8090

WORKDIR /workspace
#COPY ./run_tests.sh /workspace/

RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="pip --no-cache-dir install --upgrade --default-timeout=100" && \
    GIT_CLONE="git clone --depth 10" && \
#    chmod a+x /workspace/run_tests.sh && \

# ==================================================================
# System Packages & Tools
# ------------------------------------------------------------------

    apt-get update --fix-missing && \
    apt-get install -y \
        nginx \
        nodejs \
        npm \
#        libopencv-highgui3.2 \
#        gcc \
#        procps \
        binutils && \
    apt-get clean && \

# ==================================================================
# Essesntial Packages
# ------------------------------------------------------------------

    conda install -y \
        psutil \
        Cython \
        numpy \
        scipy \
        pandas \
        scikit-learn \
        matplotlib \
        seaborn 

#RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
#    PIP_INSTALL="pip --no-cache-dir install --upgrade --default-timeout=100" && \
#    GIT_CLONE="git clone --depth 10" && \

# ==================================================================
# Tensorflow
# ------------------------------------------------------------------

#    conda install -y \
#        tensorflow==2.5.0 
# ==================================================================
# PyTorch
# ------------------------------------------------------------------

RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="pip --no-cache-dir install --upgrade --default-timeout=100" && \
    GIT_CLONE="git clone --depth 10" && \

    conda install -y \
        pytorch==1.8.0 \
        torchvision torchaudio cpuonly -c pytorch && \
    conda install -c conda-forge -y \
        pytorch-lightning

#    $PIP_INSTALL \
#        torch_optimizer \
#        # PyTorch Geometric
#        # https://pytorch-geometric.com/whl/
#        torch-scatter -f https://pytorch-geometric.com/whl/torch-1.7.0+cpu.html \
#        torch-sparse -f https://pytorch-geometric.com/whl/torch-1.7.0+cpu.html \
#        torch-cluster -f https://pytorch-geometric.com/whl/torch-1.7.0+cpu.html \
#        torch-spline-conv -f https://pytorch-geometric.com/whl/torch-1.7.0+cpu.html \
#        torch-geometric \
#        && \

# ==================================================================
# Additional Packages
# ------------------------------------------------------------------

RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="pip --no-cache-dir install --upgrade --default-timeout=100" && \
    GIT_CLONE="git clone --depth 10" && \

    conda install -c conda-forge -y \
        gensim \
        transformers \
        optuna \
        yellowbrick \
        plotly \
        shap \
        gym \
        flask \
        networkx \
        websocket-client \
        && \

    $PIP_INSTALL \
        # NLP
        zhconv \
        jieba \
        ckiptagger \
        spacy \
        iterative-stratification \
        && \

    # LightGBM, Xgboost
    conda install -c conda-forge -y \
        lightgbm xgboost \
        && \

    # Jupyter Notebook
    $PIP_INSTALL \
        yapf \
        jupyter \
        jupyterlab \
        jupyter_contrib_nbextensions \
        jupyter_nbextensions_configurator \
        jedi==0.17.2 \
        parso==0.7.1 \
        nbconvert==5.6.1 \
#         opencv-python=4.4.0.36 \
        # apache-airflow==2.0.2 \
        && \
    jupyter contrib nbextension install --user && \
    jupyter nbextension enable code_prettify/code_prettify && \
    jupyter nbextension enable collapsible_headings/main && \
    jupyter nbextension enable toggle_all_line_numbers/main

# ==================================================================
# OpenCV
# ------------------------------------------------------------------

#    apt-get install -y \
#        build-essential \
#        cmake && \
#    ln -s /opt/conda/lib/python3.8/site-packages/numpy/core/include/numpy /usr/include/numpy && \
#    $GIT_CLONE --branch 4.4.0 https://github.com/opencv/opencv ~/opencv && \
#    mkdir -p ~/opencv/build && cd ~/opencv/build && \
#    cmake -D CMAKE_BUILD_TYPE=RELEASE \
#          -D CMAKE_INSTALL_PREFIX=/opt/conda \
#          -D WITH_IPP=OFF \
#          -D WITH_CUDA=OFF \
#          -D WITH_OPENCL=OFF \
#          -D BUILD_TESTS=OFF \
#          -D BUILD_PERF_TESTS=OFF \
#          -D BUILD_opencv_python3=ON \
#          -D PYTHON_DEFAULT_EXECUTABLE=/opt/conda/bin/python \
#          -D PYTHON3_NUMPY_INCLUDE_DIRS=/opt/conda/lib/python3.8/site-packages/numpy/core/include \
#          -D PYTHON3_LIBRARIES=/opt/conda/lib/libpython3.8.so \
#          -D PYTHON3_INCLUDE_DIR=/opt/conda/include/python3.8 \
#          -D PYTHON3_EXECUTABLE=/opt/conda/bin/python \
#          -D PYTHON3_PACKAGES_PATH=/opt/conda/lib/python3.8/site-packages \
#          .. && \
#    make -j"$(nproc)" install && \
#    python -c "import cv2; print(cv2.__version__)" && \
#    apt-get remove -y build-essential cmake && \

# ==================================================================
# Config & Cleanup
# https://jcristharif.com/conda-docker-tips.html
# ------------------------------------------------------------------
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="pip --no-cache-dir install --upgrade --default-timeout=100" && \
    GIT_CLONE="git clone --depth 10" && \

    ldconfig && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \

    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.pyc' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    find /opt/conda/lib/python3.*/ -name 'tests' -exec rm -r '{}' + && \
    find /opt/conda/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; && \

    apt-get remove -y binutils && \
    apt-get clean -y && \
    apt-get autoremove -y && \
    conda clean --all -y && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*
