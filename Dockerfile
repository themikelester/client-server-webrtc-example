FROM ubuntu:latest

LABEL maintainer="themikelester@gmail.com"

# Install system-wide deps C++ and Boost building
RUN apt-get -yqq update
RUN apt-get -yqq install cmake git

# Install app-specific deps
# TODO: We only need Boost.asio, can we reduce the dep size? (this is 750MB)
RUN apt-get -yqq install libboost-all-dev 

# Install Google's libwebrtc via a modified version of aisouard's scripts
# See http://blog.brkho.com/2017/03/15/dive-into-client-server-web-games-webrtc/
RUN apt-get -yqq install build-essential libglib2.0-dev libgtk2.0-dev libxtst-dev \
    libxss-dev libpci-dev libdbus-1-dev libgconf2-dev \
    libgnome-keyring-dev libnss3-dev libasound2-dev libpulse-dev \
    libudev-dev
RUN git clone https://github.com/themikelester/libwebrtc-m72.git /opt/libwebrtc-build
RUN mkdir /opt/libwebrtc-build/out
WORKDIR /opt/libwebrtc-build/out
# Let's lock to a specific release. The latest as of 2020/04/07 is 72
RUN cmake -DWEBRTC_BRANCH_HEAD=refs/branch-heads/72 ..
RUN make 
RUN make install

# Build the server
COPY server /opt/server
WORKDIR /opt/server
RUN cmake ./
RUN make

# Expose ports

# Run the server
CMD ["echo done"]