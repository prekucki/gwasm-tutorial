FROM debian:stable
RUN apt-get update && apt-get install -y build-essential curl gcc git python libxml2 cmake

# Install Rust
ENV RUSTUP_HOME=/opt/rust
ENV CARGO_HOME=/opt/cargo
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH=$PATH:/opt/cargo/bin

# Install emscripten
RUN rustup target add wasm32-unknown-emscripten
RUN cd /opt && \
	git clone https://github.com/emscripten-core/emsdk.git &&  \
	cd emsdk && \
	/opt/emsdk/emsdk install latest
ENV EMSDK=/opt/emsdk
ENV PATH=$PATH:/opt/emsdk
RUN emsdk activate latest
ENV PATH=$PATH:/opt/emsdk/fastcomp/emscripten:/opt/emsdk/node/8.9.1_64bit/bin

# Install hello example
COPY repos/hello-gwasm-runner/ /root/hello/
RUN cd /root/hello/ && cargo build --release

# Install mandelbrot
RUN cd /root && git clone https://github.com/golemfactory/mandelbrot.git
RUN cd /root/mandelbrot && cargo build --release 

# Install gudot
COPY repos/gudot/ /root/gudot/
RUN cd /root/hello/ && cargo build --release

# Install rust key crackers
COPY repos/key_cracker_demo/ /root/key_cracker_demo/
COPY repos/key_cracker_gen/ /root/key_cracker_gen/
RUN cd /root/key_cracker_demo/ && cargo build --release
RUN cd /root/key_cracker_gen/ && cargo build --release

# Install c++ key crackers
COPY repos/key_cracker_cpp/ /root/key_cracker_cpp/
RUN cd /root/key_cracker_cpp/ && \
    mkdir -p build && \
    cd build && \
    emconfigure cmake .. && \
    make

RUN cd /root/hello 
WORKDIR /root/hello
