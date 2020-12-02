#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM centos:centos8

ENV JAVA_HOME /usr/lib/jvm/zulu11

RUN \
    set -xeu && \
    # dependencies
    dnf -y -q install https://cdn.azul.com/zulu/bin/zulu-repo-1.0.0-1.noarch.rpm && \
    dnf -y -q install zulu11 less python3 && \
    alternatives --set python /usr/bin/python3 && \
    dnf -q clean all && \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/* && \
    # set up user
    groupadd presto --gid 1000 && \
    useradd presto --uid 1000 --gid 1000

ENV PRESTO_VERSION 347

ENV PRESTO_LOCATION="https://repo1.maven.org/maven2/io/prestosql/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz"
ENV CLIENT_LOCATION="https://repo1.maven.org/maven2/io/prestosql/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar"

RUN \
    set -xeu && \
    # install client
    curl -o /usr/bin/presto ${CLIENT_LOCATION} && \
    chmod +x /usr/bin/presto && \
    # install server
    mkdir -p /usr/lib/presto /data/presto && \
    curl ${PRESTO_LOCATION} | tar -C /usr/lib/presto -xz --strip 1 && \
    chown -R "presto:presto" /usr/lib/presto /data/presto

COPY --chown=presto:presto bin /usr/lib/presto/bin
COPY --chown=presto:presto default /usr/lib/presto/default

EXPOSE 8080
USER presto:presto
ENV LANG en_US.UTF-8
CMD ["/usr/lib/presto/bin/run-presto"]
