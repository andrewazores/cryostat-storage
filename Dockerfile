ARG builder_version=8.9
ARG runner_version=8.9

FROM registry.access.redhat.com/ubi8/ubi:${builder_version} AS builder
ARG ref=master
RUN dnf install -y go git make gettext \
    && pushd /root \
    && git clone --depth 1 --branch $ref https://github.com/seaweedfs/seaweedfs \
    && pushd seaweedfs/weed \
    && make install \
    && popd \
    && popd

FROM registry.access.redhat.com/ubi8/ubi-micro:${runner_version}
COPY --from=builder /usr/bin/envsubst /usr/bin/
COPY --from=builder /root/go/bin/weed /usr/bin/weed
COPY --from=builder /root/seaweedfs/docker/entrypoint.sh /usr/local
COPY ./cryostat-entrypoint.bash /usr/local/
COPY seaweed_conf.template.json /etc/seaweed_conf.template.json
ENTRYPOINT ["/usr/local/cryostat-entrypoint.bash"]
