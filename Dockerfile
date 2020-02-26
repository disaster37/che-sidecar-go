# Copyright (c) 2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM node:10.16-alpine

ENV HOME=/home/theia

RUN mkdir /projects ${HOME} && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done

RUN set -e \
    && \
    apk add --update --no-cache  --virtual .build-deps \
        bash \
        gcc g++ \
        musl-dev \
        openssl \
        go \
        git \
    && \
    export \
        GOROOT_BOOTSTRAP="$(go env GOROOT)" \
        GOOS="$(go env GOOS)" \
        GOARCH="$(go env GOARCH)" \
        GOHOSTOS="$(go env GOHOSTOS)" \
        GOHOSTARCH="$(go env GOHOSTARCH)" \
    && \
    apkArch="$(apk --print-arch)" \
    && \
    case "$apkArch" in \
        armhf) export GOARM='6' ;; \
        x86) export GO386='387' ;; \
    esac \
    && \
    wget -qO- https://dl.google.com/go/go1.13.8.linux-amd64.tar.gz | tar xvz -C /usr/local && \
    cd /usr/local/go/src &&    ./make.bash && \
    rm -rf /usr/local/go/pkg/bootstrap /usr/local/go/pkg/obj && \
    export GOPATH="/go" && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg" && \
    export PATH="$GOPATH/bin:/usr/local/go/bin:$PATH" && \
    go get -u -v github.com/ramya-rao-a/go-outline@latest && \
    go get -u -v github.com/acroca/go-symbols@latest &&  \
    go get -u -v github.com/stamblerre/gocode@latest &&  \
    go get -u -v github.com/rogpeppe/godef@latest && \
    go get -u -v golang.org/x/tools/cmd/godoc@latest && \
    go get -u -v github.com/zmb3/gogetdoc@latest && \
    go get -u -v golang.org/x/lint/golint@latest && \
    go get -u -v github.com/fatih/gomodifytags@latest &&  \
    go get -u -v golang.org/x/tools/cmd/gorename@latest && \
    go get -u -v sourcegraph.com/sqs/goreturns@latest && \
    go get -u -v golang.org/x/tools/cmd/goimports@latest && \
    go get -u -v github.com/cweill/gotests@latest && \
    go get -u -v golang.org/x/tools/cmd/guru@latest && \
    go get -u -v github.com/josharian/impl@latest && \
    go get -u -v github.com/haya14busa/goplay/cmd/goplay@latest && \
    go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct@latest && \
    go get -u -v github.com/go-delve/delve/cmd/dlv@latest && \
    go get -u -v github.com/rogpeppe/godef@latest && \
    go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs@v2 && \
    go get -u -v golang.org/x/tools/cmd/gotype@latest && \
    go get -u -v golang.org/x/tools/gopls@latest && \
    go get -u -v github.com/stamblerre/gocode@latest && \
    chmod -R 777 "$GOPATH" && \
    apk del .build-deps && \
    mkdir /.cache && chmod -R 777 /.cache && \
    wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.22.2

# Add git for go mode
RUN set -e \
    && \
    apk add --update git curl

ENV GOPATH /go
ENV GOCACHE /.cache
ENV GOROOT /usr/local/go
ENV GO111MODULE on
ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH

ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
