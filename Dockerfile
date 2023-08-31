FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

WORKDIR /

RUN mkdir /workspace

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive\
    SHELL=/bin/bash\
    VSCODE_SERVE_MODE=remote
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
RUN apt-get install -y --no-install-recommends software-properties-commo
RUN wget -q -O- https://aka.ms/install-vscode-server/setup.sh | sh 
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN pip install --no-cache-dir --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu121
RUN pip install --no-cache-dir -U jupyterlab ipywidgets jupyter-archive notebook==6.5.4
RUN jupyter nbextension enable --py widgetsnbextension
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

ADD start.sh /

RUN chmod +x /start.sh

CMD [ "/start.sh" ]
