# https://github.com/jgoerzen/docker-debian-base-minimal
# https://changelog.complete.org/archives/9794-fixing-the-problems-with-docker-images
# https://hub.docker.com/r/jgoerzen/debian-base-minimal
FROM jgoerzen/debian-base-minimal:buster@sha256:6ec22e9274cccc1929124b141a389542542db8974f05a500e11923a2dbcc11a9

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
&& apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
#    sudo \
#    fonts-liberation \
# For pyenv per https://realpython.com/intro-to-pyenv/
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python-openssl \
# Also pyenv, but I'll keep these
    curl \
    make \
    build-essential \
    git \
# For terminal sanity
    less \
    nano \
# For pyenv per https://realpython.com/intro-to-pyenv/
&& curl https://pyenv.run | bash \
&& /root/.pyenv/bin/pyenv install 3.7.2 \
&& /root/.pyenv/bin/pyenv global 3.7.2 \
# Now remove pyenv dependencies (cant be separate RUN command or else this won't shed weight)
# NOTE: thus pyenv won't work in the vm
&& apt-get remove -yq --purge  binfmt-support fontconfig-config fonts-dejavu-core \
     libbz2-dev libedit2 libexpat1-dev libffi-dev libfontconfig1-dev \
     libfreetype6-dev libfreetype6 libglib2.0-0 libice-dev libice6 libllvm7 \
     libncurses-dev libncurses5-dev libncursesw5-dev libpipeline1 libpng-dev \
     libpthread-stubs0-dev libpython-stdlib libpython2-stdlib \
     libpython2.7-stdlib libreadline-dev libreadline7 libsm-dev libsm6 \
     libssl-dev libtcl8.6 libtk8.6 libx11-6 libx11-data libx11-dev libxau-dev \
     libxcb1-dev libxcb1 libxdmcp-dev libxdmcp6 libxext-dev libxext6 \
     libxft2 libxrender-dev libxrender1 libxss-dev libxss1 libxt-dev libxt6 \
     llvm-7 llvm-runtime llvm mime-support pkg-config python-asn1crypto \
     python-cryptography python-enum34 python-ipaddress python-minimal \
     python-six python2-minimal python2.7-minimal python2.7 python2 python \
     tcl-dev tcl8.6-dev tcl8.6 tcl tk-dev tk8.6-dev tk8.6 tk ucf uuid-dev \
     x11proto-core-dev x11proto-dev x11proto-scrnsaver-dev x11proto-xext-dev \
     xtrans-dev zlib1g-dev \
&& apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# Install Jupyter notebook
ADD files/requirements_jupyter.txt /root/
RUN /root/.pyenv/shims/pip install --no-cache-dir --no-deps -r /root/requirements_jupyter.txt

# Install Jupyterlab extensions
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -e \
&& apt-get install -y nodejs \
&& /root/.pyenv/shims/jupyter labextension install @jupyter-widgets/jupyterlab-manager@2.0 --no-build \
&& /root/.pyenv/shims/jupyter labextension install jupyterlab-plotly@4.6.0 --no-build \
&& /root/.pyenv/shims/jupyter labextension install plotlywidget@4.6.0 --no-build \
&& /root/.pyenv/shims/jupyter labextension install ipyaggrid@0.2.1 --no-build \
# Added --minimize=False per https://github.com/jupyterlab/jupyterlab/issues/7180 to fix problem with jupyterlab-plotly
&& /root/.pyenv/shims/jupyter lab build --minimize=False --dev-build=False \
&& npm cache clean --force \
&& rm -rf /root/.pyenv/versions/3.7.2/share/jupyter/lab/staging \
&& rm -rf /usr/local/share/.cache

# Set up vm directory to mount user directory on host
RUN mkdir /user
VOLUME /user

# Home folder
ADD files/bashrc /root/.bashrc
ENV PATH="$HOME/.pyenv/bin:$PATH"

# Open port for jupyter server
EXPOSE 8888

# Warn about cruft
RUN find /root /usr -name 'cache' -exec du -sh \{\} \+ \
&& find /root /usr -name '.cache' -exec du -sh \{\} \+ \
&& find /root /usr -name 'staging' -exec du -sh \{\} \+

# Launch the server
CMD ["/root/.pyenv/shims/jupyter-notebook", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--NotebookApp.password_required=False", "--NotebookApp.token='hummingsquadshoutdeze'"]
