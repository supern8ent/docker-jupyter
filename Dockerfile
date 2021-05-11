# https://github.com/jgoerzen/docker-debian-base-minimal
# https://changelog.complete.org/archives/9794-fixing-the-problems-with-docker-images
# https://hub.docker.com/r/jgoerzen/debian-base-minimal
FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
&& apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
#    sudo \
#    fonts-liberation \
&& apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# Configure environment (per jupyter docker stacks https://github.com/jupyter/docker-stacks)
ENV SHELL=/bin/bash \
    NB_USER="jovyan" \
    NB_UID="1000" \
    NB_GID="100"
    # Got 'perl: warning: Setting locale failed.'
    # LC_ALL=en_US.UTF-8 \
    # LANG=en_US.UTF-8 \
    # LANGUAGE=en_US.UTF-8
ENV HOME=/home/$NB_USER

# Add a script that we will use to correct permissions after running certain commands
#  (per jupyter docker stacks https://github.com/jupyter/docker-stacks)
ADD files/fix-permissions /usr/local/bin/fix-permissions

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
#  (per jupyter docker stacks https://github.com/jupyter/docker-stacks)
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create NB_USER wtih name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
#  (per jupyter docker stacks https://github.com/jupyter/docker-stacks)
# RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \  # TODO
#    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
#    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    fix-permissions $HOME

USER $NB_UID
WORKDIR $HOME

# Set up vm directory to mount host's user directory
RUN mkdir /home/$NB_USER/user && \
    fix-permissions /home/$NB_USER


# For pyenv per https://realpython.com/intro-to-pyenv/
USER root
RUN apt-get update \
&& apt-get install -yq --no-install-recommends \
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
# For hdf support in pandas
    liblzo2-2 libaec0 libsnappy1v5 libgfortran5 libblosc1 libsz2 libhdf5-103 \
# For pyenv per https://realpython.com/intro-to-pyenv/
&& curl https://pyenv.run | bash \
&& $HOME/.pyenv/bin/pyenv install 3.7.2 \
&& $HOME/.pyenv/bin/pyenv global 3.7.2 \
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
&& apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/* \
&& find $HOME -exec chown $NB_UID \{\} \;

USER $NB_UID
ADD files/bashrc_pyenv.txt /tmp/
RUN cat /tmp/bashrc_pyenv.txt >> $HOME/.bashrc

# Install Jupyter notebook
USER root
ADD files/requirements_jupyter.txt /tmp/
RUN $HOME/.pyenv/shims/pip install --no-cache-dir --no-deps -r /tmp/requirements_jupyter.txt

# Install Jupyterlab extensions
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -e \
&& apt-get install -y nodejs \
&& $HOME/.pyenv/shims/jupyter labextension install @jupyter-widgets/jupyterlab-manager@2.0 --no-build \
&& $HOME/.pyenv/shims/jupyter labextension install jupyterlab-plotly@4.6.0 --no-build \
&& $HOME/.pyenv/shims/jupyter labextension install plotlywidget@4.6.0 --no-build \
&& $HOME/.pyenv/shims/jupyter labextension install ipyaggrid@0.2.1 --no-build \
# Added --minimize=False per https://github.com/jupyterlab/jupyterlab/issues/7180 to fix problem with jupyterlab-plotly
&& $HOME/.pyenv/shims/jupyter lab build --minimize=False --dev-build=False \
&& npm cache clean --force \
&& rm -rf $HOME/.pyenv/versions/3.7.2/share/jupyter/lab/staging \
&& rm -rf /usr/local/share/.cache

# pandas: pandas numpy scipy matplotlib ipywidgets
ADD files/requirements_pandas.txt /root/
RUN $HOME/.pyenv/shims/pip install --no-cache-dir --no-deps -r /root/requirements_pandas.txt
# more viz: seaborn plotly
ADD files/requirements_more_viz.txt /root/
RUN $HOME/.pyenv/shims/pip install --no-cache-dir --no-deps -r /root/requirements_more_viz.txt
# nathans oddities
ADD files/requirements_nathan.txt /root/
RUN $HOME/.pyenv/shims/pip install --no-cache-dir --no-deps -r /root/requirements_nathan.txt

# JupyterLab settings
ADD files/plugin.jupyterlab-settings $HOME/.jupyter/lab/user-settings/@jupyterlab/fileeditor-extension/
ADD files/tracker.jupyterlab-settings $HOME/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/

# More customizations
ADD files/bash_aliases.txt /tmp/
RUN cat /tmp/bash_aliases.txt >> $HOME/.bash_aliases

# Open port for jupyter server
EXPOSE 8888

# Warn about cruft
RUN find /root /usr -name 'cache' -exec du -sh \{\} \+ \
&& find /root /usr -name '.cache' -exec du -sh \{\} \+ \
&& find /root /usr -name 'staging' -exec du -sh \{\} \+

USER $NB_UID

# Launch the server
CMD ["/home/jovyan/.pyenv/shims/jupyter-notebook", "--allow-root", "--ip=0.0.0.0", "--port=8888",\
     "--notebook-dir=/home/jovyan/user", "--NotebookApp.password_required=False",\
     "--NotebookApp.token='hummingsquadshoutdeze'"]
