FROM docker.io/alpine:3.16

RUN apk add --no-cache \
    ansible \
    git \
    k9s \
    make \
    neovim \
    openssh \
    py3-pip \
    python3 \
    terraform

RUN apk add --no-cache --repository "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" \
    helm

RUN apk add --no-cache --repository "http://dl-cdn.alpinelinux.org/alpine/edge/testing" \
    kubectl

RUN pip install \
    kubernetes

ENV EDITOR=nvim
