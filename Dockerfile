ARG VER="0.2.87+arm"
ARG GO="1.25"

ARG ACT_VER="${VER}"
ARG ACT_SRC="https://github.com/drivera73/act"
ARG ACT_EXE="/act"

ARG BUILDER_IMAGE="golang"
ARG BUILDER_VER="${GO}-alpine"
ARG BUILDER_IMG="${BUILDER_IMAGE}:${BUILDER_VER}"

FROM "${BUILDER_IMG}" AS builder

ARG GO
ARG ACT_VER
ARG ACT_SRC
ARG ACT_EXE

RUN apk --no-cache add \
        bash \
        curl \
        git \
        libcap \
        make \
        nodejs \
        npm
RUN curl -fsSL "https://golangci-lint.run/install.sh" | bash

ENV BUILD="/build"

ENV GO111MODULE="on"
ENV CGO_ENABLED="0"
ENV GOOS="linux"
ENV GOARCH="amd64"

ENV ACT_PATH="${BUILD}/act"
RUN mkdir -p "${ACT_PATH}" && \
    git clone "${ACT_SRC}" "${ACT_PATH}" && \
    cd "${ACT_PATH}" && \
    git checkout "v${ACT_VER}" && \
    # go mod edit -go "${GO}" && \
    # go get -u && \
    # go mod tidy && \
    make lint-go && \
    make build && \
    cp -vf "${ACT_PATH}/dist/local/act" "${ACT_EXE}"

FROM scratch

ARG ACT_VER
ARG ACT_EXE

LABEL ORG="ArkCase LLC" \
      MAINTAINER="Armedia Devops Team <devops@armedia.com>" \
      APP="ArkCase Act Executable" \
      VERSION="${ACT_VER}"

COPY --from=builder "${ACT_EXE}" "${ACT_EXE}"

ENTRYPOINT [ "${ACT_EXE}" ]
