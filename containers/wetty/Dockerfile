FROM ubuntu:latest

ENV TZ=America/LosAngeles \
    PORT=3000 \
    UID=998 \
    GID=998 \
    USER=guest \
    ADDUSER=true \
    SECRET=password \
    SHELL=/bin/bash \
    HOME=/home/guest \
    SUDO=false \
    SSL=false \
    PKGS=none \
    CONTAINER=wetty

RUN apt-get update && apt-get install -y --no-install-recommends tzdata \
    sudo openssl curl openssh-client sshpass locales
RUN echo $TZ > /etc/timezone && apt-get install -y tzdata && \
    dpkg-reconfigure tzdata && locale-gen en_US.UTF-8 
RUN apt-get install -y --no-install-recommends git ca-certificates software-properties-common gnupg gnupg-agent
RUN apt-get install -y --no-install-recommends python3 build-essential make
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
RUN apt-get update && apt-get install -y nodejs && npm install -g yarn
RUN apt-get clean && \
    rm -rf /var/lib/apt/list/* /tmp/* /var/tmp/* 
RUN mkdir -p ~/.ssh

WORKDIR /usr/src/app
COPY ./wetty /usr/src/app/
#RUN git clone https://github.com/butlerx/wetty && cp -r wetty/* . && rm -rf wetty/
RUN yarn && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline

EXPOSE 3000

ADD ./bootstrap.sh /usr/local/sbin

ENTRYPOINT [ "bootstrap.sh" ]
CMD [ "wetty" ]

