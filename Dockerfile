FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

WORKDIR /

RUN mkdir /workspace

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive\
    SHELL=/bin/bash\
    VSCODE_SERVE_MODE=remote
RUN . /etc/lsb-release && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | \
    env os=ubuntu dist="${DISTRIB_CODENAME}" bash
RUN apt-get update --yes && \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends\
    git\
    wget\
    curl\
    bash\
    software-properties-common\
    openssh-server\
    libaio-dev\
    python3-pip
RUN curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz && \
    tar -xf vscode_cli.tar.gz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/code && rm -f vscode_cli.tar.gz
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN pip install --no-cache-dir --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu121
RUN pip install --no-cache-dir -U jupyterlab ipywidgets jupyter-archive notebook==6.5.4
RUN jupyter nbextension enable --py widgetsnbextension
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

ADD start.sh /

RUN chmod +x /start.sh

CMD [ "/start.sh" ]
