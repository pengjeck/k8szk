FROM ubuntu:16.04

ENV ZK_USER=zookeeper \
    ZK_DATA_DIR=/var/lib/zookeeper/data \
    ZK_DATA_LOG_DIR=/var/lib/zookeeper/log \
    ZK_LOG_DIR=/var/log/zookeeper \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ARG GPG_KEY=3F7A1D16FA4217B1DC75E1C9FFE35B7F15DFA1BA
ARG ZK_DIST=zookeeper-3.7.0

RUN set -x \
    && apt-get update \
    && apt-get install -y openjdk-8-jre-headless wget netcat-openbsd \
    && wget -q "http://www.apache.org/dist/zookeeper/$ZK_DIST/apache-$ZK_DIST-bin.tar.gz" \
    && export GNUPGHOME="$(mktemp -d)" \
    && tar -xzf "apache-$ZK_DIST-bin.tar.gz" -C /opt \
    && rm -r "$GNUPGHOME" "apache-$ZK_DIST-bin.tar.gz" \
    && ln -s /opt/apache-$ZK_DIST-bin /opt/zookeeper \
    && apt-get autoremove -y wget \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration generator script to bin
COPY zkGenConfig.sh zkOk.sh zkMetrics.sh /opt/zookeeper/bin/

# Create a user for the zookeeper process and configure file system ownership
# for necessary directories and symlink the distribution as a user executable
RUN set -x \
    && useradd $ZK_USER \
    && [ `id -u $ZK_USER` -eq 1000 ] \
    && [ `id -g $ZK_USER` -eq 1000 ] \
    && mkdir -p $ZK_DATA_DIR $ZK_DATA_LOG_DIR $ZK_LOG_DIR /usr/share/zookeeper /tmp/zookeeper /usr/etc/ \
    && chown -R "$ZK_USER:$ZK_USER" /opt/apache-$ZK_DIST-bin $ZK_DATA_DIR $ZK_LOG_DIR $ZK_DATA_LOG_DIR /tmp/zookeeper \
    && ln -s /opt/zookeeper/conf/ /usr/etc/zookeeper \
    && ln -s /opt/zookeeper/bin/* /usr/bin \
    && ln -s /opt/zookeeper/lib/* /usr/share/zookeeper
