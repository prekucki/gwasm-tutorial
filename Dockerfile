FROM debian:stable
RUN apt-get update && apt-get install -y build-essential curl gcc git python libxml2
ENV RUSTUP_HOME=/opt/rust
ENV CARGO_HOME=/opt/cargo
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH=$PATH:/opt/cargo/bin
RUN rustup target add wasm32-unknown-emscripten
RUN cd /opt && \
	git clone https://github.com/emscripten-core/emsdk.git &&  \
	cd emsdk && \
	/opt/emsdk/emsdk install latest
ENV EMSDK=/opt/emsdk
ENV PATH=$PATH:/opt/emsdk
RUN emsdk activate latest
ENV PATH=$PATH:/opt/emsdk/fastcomp/emscripten:/opt/emsdk/node/8.9.1_64bit/bin
RUN cd && USER=golemdev cargo init hello
RUN cd /root/hello && echo cargo build --target wasm32-unknown-emscripten > build.sh && chmod +x build.sh
WORKDIR /root/hello

