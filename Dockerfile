FROM golang:1.14-alpine

RUN apk add --no-cache curl git bash jq && rm -rf /var/cache/apk/*

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

RUN   curl --retry 7 -Lo /tmp/client-tools.tar.gz "https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz"

# install openshift client
RUN   tar zxf /tmp/client-tools.tar.gz -C /usr/local/bin oc && \
      mv /usr/local/bin/oc /usr/local/bin/ocexe && \
      rm /tmp/client-tools.tar.gz 

# create alias for oc
RUN   echo -e '#!/bin/bash\n/lib/ld-musl-x86_64.so.1 --library-path /lib /usr/local/bin/ocexe "$@"' > /usr/bin/oc && \
      chmod +x /usr/bin/oc

ENTRYPOINT ["bash"]
