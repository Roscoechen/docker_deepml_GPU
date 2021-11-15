# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/debian/Dockerfile
# https://conda.io/projects/conda/en/latest/commands.html#conda-vs-pip-vs-virtualenv-commands
# 
# docker build --rm=true --no-cache=true -t guitarmind/deepml-cpu -f ./Dockerfile .
# docker run --rm -p 8888:8888 -p 6006:6006 --name deepml-cpu -it guitarmind/deepml-cpu bash
# 

FROM anibali/pytorch:1.8.1-cuda11.1-ubuntu20.04

LABEL MAINTAINER="Roscoe Chen"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    # Disabling SSL verification
    SSL_NO_VERIFY=1 \
    PATH=/opt/conda/bin:$PATH \
    PYTHONDONTWRITEBYTECODE=true \
    TZ=Asia/Taipei

RUN sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

EXPOSE 8888 6006 8090

WORKDIR /workspace
#COPY ./run_tests.sh /workspace/

RUN sudo apt-get update \
 #&& sudo apt-get update --fix-missing \
 && sudo apt-get install -y gcc build-essential libgl1-mesa-glx libgtk2.0-0 libsm6 libxext6
 
# Install OpenCV from PyPI.
RUN pip install opencv-python==4.5.1.48

RUN APT_INSTALL="sudo apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="pip --no-cache-dir install --upgrade --default-timeout=100" && \
    GIT_CLONE="git clone --depth 10" && \
#    chmod a+x /workspace/run_tests.sh && \

# ==================================================================
# Essesntial Packages
# ------------------------------------------------------------------

    pip install \
        psutil \
        Cython \
        numpy \
        scipy \
        pandas \
        scikit-learn \
        matplotlib \
        seaborn && \

    pip install tensorflow && \ 


# ==================================================================
# Additional Packages
# ------------------------------------------------------------------

    pip install \
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
    #    zhconv \
        jieba \
        ckiptagger \
        spacy \
        iterative-stratification \
        && \

    # LightGBM, Xgboost
    pip install \
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
    jupyter nbextension enable toggle_all_line_numbers/main && \

# ==================================================================
# Config & Cleanup
# https://jcristharif.com/conda-docker-tips.html
# ------------------------------------------------------------------

    #sudo ldconfig && \
    #sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \

    #find /opt/conda/ -follow -type f -name '*.a' -delete && \
    #find /opt/conda/ -follow -type f -name '*.pyc' -delete && \
    #find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    #find /opt/conda/lib/python3.*/ -name 'tests' -exec rm -r '{}' + && \
    #find /opt/conda/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; && \

    sudo apt-get remove -y binutils && \
    sudo apt-get clean -y && \
    sudo apt-get autoremove -y && \
    #conda clean --all -y && \
    sudo rm -rf /tmp/* && \
    sudo rm -rf /var/cache/apk/*
