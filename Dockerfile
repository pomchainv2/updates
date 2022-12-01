FROM ubuntu:20.04

RUN mkdir -p /home/app

COPY . /home/app
# set default dir so that next commands executes in /home/app dir
WORKDIR /home/app

ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt -y upgrade && \
    apt -y install g++ cargo make gcc inotify-tools automake git libtool wget gnupg gnupg1 gnupg2 curl lsb-release && \
    wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && dpkg -i erlang-solutions_2.0_all.deb && \
    apt -y update && \
    apt -y install esl-erlang && \
    apt -y install elixir &&  \
    curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt -y install nodejs && \
    rm -rf /var/lib/apt/lists/*
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

RUN mix local.hex --force
RUN mix do deps.get, local.rebar --force, deps.compile

RUN cd apps/block_scout_web/assets; npm install && node_modules/webpack/bin/webpack.js --mode production; cd -
RUN cd apps/explorer && npm install; cd -


# CMD PORT=4000 mix phx.server
CMD ["/home/app/entrypoint.sh"]
