FROM golang:1.14-alpine
#RUN echo -e "http://nl.alpinelinux.org/alpine/v3.5/main\nhttp://nl.alpinelinux.org/alpine/v3.5/community" > /etc/apk/repositories
RUN apk add --no-cache curl git bash && rm -rf /var/cache/apk/*

WORKDIR /go/src/github.com/kubernetes-incubator/auger
ADD     . /go/src/github.com/kubernetes-incubator/auger
RUN     go build && go install && chmod +x /go/bin/auger

ENV    ETCD_VER=v3.4.13
# choose either URL
ENV    GOOGLE_URL=https://storage.googleapis.com/etcd
ENV    GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
ENV    DOWNLOAD_URL=${GOOGLE_URL}

RUN    rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz && \
       rm -rf /tmp/etcd-download-test && \
       mkdir -p /tmp/etcd-download-test

RUN    curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz && \
       tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1 && \
       rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

RUN    /tmp/etcd-download-test/etcd --version
RUN    /tmp/etcd-download-test/etcdctl version

RUN    mv /tmp/etcd-download-test/etcdctl /bin/
RUN    rm -Rf /tmp/etcd-download-test /var/cache/apk/*

ENTRYPOINT ["bash"]
