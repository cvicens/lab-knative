FROM quay.io/openshifthomeroom/workshop-dashboard:4.2.2

ENV STAGE_DIR=/tmp/stage BIN_DIR=/usr/local/bin \
    KNATIVE_CLI_VERSION=0.2.0 TEKTON_CLI_VERSION=0.4.0 \
    KAMEL_CLI_VERSION=1.0.0-RC2

USER root

RUN mkdir -p ${STAGE_DIR} && cd ${STAGE_DIR} && \
    curl -OL https://github.com/knative/client/releases/download/v${KNATIVE_CLI_VERSION}/kn-linux-amd64 && \
    chmod a+x kn-linux-amd64 && mv kn-linux-amd64 ${BIN_DIR}/kn && \
    curl -OL https://github.com/tektoncd/cli/releases/download/v${TEKTON_CLI_VERSION}/tkn_${TEKTON_CLI_VERSION}_linux_x86_64.tar.gz && \
    tar xvzf tkn_${TEKTON_CLI_VERSION}_linux_x86_64.tar.gz && mv tkn ${BIN_DIR} && \
    curl -OL https://storage.googleapis.com/hey-release/hey_linux_amd64 && \
    chmod a+x hey_linux_amd64 && mv hey_linux_amd64 ${BIN_DIR}/hey && \
    cd ${STAGE_DIR} && curl -OL https://github.com/apache/camel-k/releases/download/${KAMEL_CLI_VERSION}/camel-k-client-${KAMEL_CLI_VERSION}-linux-64bit.tar.gz && \
    tar xvzf camel-k-client-${KAMEL_CLI_VERSION}-linux-64bit.tar.gz && chmod a+x kamel && mv kamel ${BIN_DIR}
    
RUN rm -rf ${STAGE_DIR} 

COPY . /tmp/src

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src

ENV TERMINAL_TAB=split

USER 1001

RUN /usr/libexec/s2i/assemble
