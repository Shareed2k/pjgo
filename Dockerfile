FROM golang:1.11-alpine as builder
LABEL maintainer="Roman Kredentser <shareed2k@gmail.com>"

ARG VERSION_PJSIP=2.8

RUN apk add --no-cache \
    alpine-sdk \
    pjproject-dev \
    swig \
    && cd \
    && wget -qnv "http://www.pjsip.org/release/$VERSION_PJSIP/pjproject-$VERSION_PJSIP.tar.bz2" -O - | tar xjf - \
    && cd pjproject-$VERSION_PJSIP \
    && ./configure \
      --disable-oss \
      --disable-sdl \
      --disable-speex-aec \
      --disable-video \
      --prefix=/usr/local \
      > /dev/null \
    && make dep \
    && make \
    && make install

WORKDIR /opt/src

COPY . .

RUN export GO111MODULE=on

RUN cd pjsua2/ && swig -c++ -go -cgo -intgosize 64 -outcurrentdir -I/usr/local/include ~/pjproject-$VERSION_PJSIP/pjsip-apps/src/swig/pjsua2.i \
    && cd ../ && go build -o /go/bin/gug

EXPOSE 5060
ENTRYPOINT ["/go/bin/gug"]