# syntax=hub.docker.prod.<priv-dom>/docker/dockerfile:1
FROM hub.docker.prod.<priv-dom>/library/python:3.9-buster

ENV ACCEPT_EULA=Y
RUN rm -rfv /var/lib/apt/lists/*
RUN echo "deb [trusted=yes] http://ark-repos.<priv-dom>/ark/apt/published/debian/10.0/direct/soe/noenv/os/ buster main" > /etc/apt/sources.list
RUN echo "deb [trusted=yes] http://ark-repos.<priv-dom>/ark/apt/published/debian/10.0/direct/soe/noenv/updates/ buster-updates main" >> /etc/apt/sources.list
RUN echo "deb [trusted=yes] http://ark-repos.<priv-dom>/ark/apt/published/debian/10.0/direct/soe/noenv/security/ buster-updates main" >> /etc/apt/sources.list
RUN echo "deb [trusted=yes] http://ark-repos.<priv-dom>/ark/apt/published/debian/10.0/direct/soe/noenv/third-party/ buster main" >> /etc/apt/sources.list
RUN echo "deb [trusted=yes] http://ark-repos.<priv-dom>/ark/apt/published/debian/10.0/direct/soe/noenv/wm-apps/ buster main" >> /etc/apt/sources.list
# RUN echo "deb [trusted=yes] https://repository.cache.<priv-dom>/repository/debian-releases/ buster-updates main" >> /etc/apt/sources.list
# RUN echo "deb [trusted=yes] https://repository.cache.<priv-dom>/repository/debian-releases/ buster main" >> /etc/apt/sources.list
# RUN curl -sSL "https://repository.cache.<priv-dom>/repository/microsoft-apt-ubuntu/keys/microsoft.asc" | apt-key add -
# RUN echo "deb [trusted=yes] https://repository.cache.<priv-dom>/repository/microsoft-apt-ubuntu/debian/10/prod buster main" >> /etc/apt/sources.list
RUN apt-get upgrade
RUN apt-get update && apt-get install -y build-essential \
	libssl-dev \
	git \
	wget \
	lsb-release \
	curl \
	unixodbc-dev \
    gnupg \
    nginx

ARG USERNAME=nonroot
ARG USER_UID=1000
ARG USER_GID=$USER_UID

WORKDIR /

# Install gcloud for gcs connection
RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin

COPY proximity.pip.ini /.config/pip/pip.conf

RUN apt-get update && apt-get install -y default-jre

COPY requirements.txt /requirements.txt

# For cached pip packages to speed up install

# RUN python -m pip cache purge # Only enable this if things are going wrong with installs - otherwise will slow build
RUN python -m pip config set global.index-url https://pypi.ci.artifacts.<priv-dom>/artifactory/api/pypi/pythonhosted-pypi-release-remote/simple/
RUN python -m pip config set global.trusted-host pypi.ci.artifacts.<priv-dom>
# The following command mounts a local cache directory (or attempts to) in order to speed up pip installs for the bulk of packages
# RUN --mount=type=cache,mode=0777,target=./pipcache \ # TODO: This should make things faster on local build time but isn't working on my system
RUN python -m pip install -r /requirements.txt --default-timeout=1500
# Force upgrade sqlalchemy to langchain compatible version - conflicts with golden signals package
RUN python -m pip install sqlalchemy==2.0.25 --default-timeout=1500
# Force install uvicorn latest
# RUN python -m pip install uvicorn==0.27.0.post1 --default-timeout=1500


# Copy app scripts
COPY app/ /app
COPY start_server.sh start_server.sh
# COPY startup_scripts /startup_scripts

ENV PYTHONPATH="${PYTHONPATH}:/"
ENV HTTP_PROXY=sysproxy.<priv-dom>:8080
ENV HTTPS_PROXY=sysproxy.<priv-dom>:8080

# Make secrets directory
##COPY secrets/ /secrets

# Configure NGINX Proxy
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /var/nginx/log
RUN touch /var/nginx/log/error.log
RUN chmod -R 770 /var/nginx
RUN chown -R 10000:10001 /var/nginx
RUN touch /run/nginx.pid \
 && chown -R $USER_UID:$USER_GID /run/nginx.pid

# Set up first time run scripts
RUN chmod 755 start_server.sh
# RUN chmod -R 755 /startup_scripts

#Non Root User Configuration
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && chown -R $USER_UID:$USER_GID start_server.sh \
    && chown -R $USER_UID:$USER_GID /app \
##    && chown -R $USER_UID:$USER_GID /projects \
    && chown -R $USER_UID:$USER_GID /mnt \
##    && chown -R $USER_UID:$USER_GID /secrets \
    # && chown -R $USER_UID:$USER_GID /startup_scripts \
    && chown -R $USER_UID:$USER_GID /var

USER $USER_UID

EXPOSE 8080

CMD [ "/bin/bash", "-c", "./start_server.sh" ]
