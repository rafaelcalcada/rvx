# Base image
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV PATH="/home/rvx/.local/bin:${PATH}"

# 1. Install all necessary packages in a single step
RUN apt-get update && apt-get install -y --ignore-missing \
  sudo build-essential curl git python3 python3-pip python3-venv vim cmake ninja-build \
  flex bison gdb bash-completion clang-format ccache ssh help2man perl make autoconf g++ \
  libgoogle-perftools-dev numactl perl-doc libfl2 libfl-dev zlib1g-dev automake autotools-dev \
  python3-tomli libmpc-dev libmpfr-dev libgmp-dev gawk texinfo gperf libtool patchutils bc \
  libexpat-dev libglib2.0-dev libslirp-dev locales unzip gnupg device-tree-compiler \
  libboost-regex-dev libboost-system-dev && locale-gen en_US.UTF-8 && \
  update-locale LANG=en_US.UTF-8 && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Create the RVX user
RUN if id -u ubuntu 2>/dev/null; then \
  userdel -r ubuntu || true; \
  fi && \
  groupadd -g 1000 rvx && useradd -m -g 1000 -s /bin/bash rvx && \
  echo "rvx ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 3. Install Verilator
RUN git clone https://github.com/verilator/verilator.git /tmp/verilator && \
  cd /tmp/verilator && git checkout stable && autoconf && \
  ./configure && make -j$(nproc) && make install && \
  rm -rf /tmp/verilator

# 4. Install Bazel
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel-archive-keyring.gpg && \
  mv bazel-archive-keyring.gpg /usr/share/keyrings && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list && \
  apt-get update && apt-get install -y bazel-7.6.0 && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# 5. Install Verible
RUN git clone https://github.com/chipsalliance/verible.git /tmp/verible && \
  cd /tmp/verible && bazel-7.6.0 build -c opt :install-binaries && \
  /tmp/verible/.github/bin/simple-install.sh /usr/local/bin/ && \
  rm -rf /tmp/verible

# 6. Install the RISC-V GNU Toolchain
RUN git clone https://github.com/riscv/riscv-gnu-toolchain /tmp/riscv-gnu-toolchain && \
  cd /tmp/riscv-gnu-toolchain && \
  ./configure --with-arch=rv32izicsr --with-abi=ilp32 --prefix=/usr/local && \
  make -j$(nproc) && make install && \
  rm -rf /tmp/riscv-gnu-toolchain

# 7. Install Universal Ctags
RUN git clone https://github.com/universal-ctags/ctags.git /tmp/ctags && \
  cd /tmp/ctags && ./autogen.sh && ./configure && make -j$(nproc) && make install && \
  rm -rf /tmp/ctags

# 8. Customize bash prompt
RUN echo "PS1='\[\033[01;32m\]\u@\h \[\033[01;34m\]\w\[\033[01;33m\]\$(__git_ps1 \" (%s)\")\[\033[00m\] \$ '" >> /home/rvx/.bashrc

# 9. Install RISC-V Spike Simulator
RUN git clone https://github.com/riscv-software-src/riscv-isa-sim.git /tmp/riscv-isa-sim && \
  cd /tmp/riscv-isa-sim && mkdir build && cd build && \
  ../configure --prefix=/usr/local && \
  make -j$(nproc) && make install && \
  rm -rf /tmp/riscv-isa-sim

# 10. Use the venv binaries
ENV PATH="/opt/venv/bin:$PATH"

USER rvx
WORKDIR /home/rvx

# 11. Add bash aliases
RUN echo "alias ll='ls -la'" >> /home/rvx/.bash_aliases && \
  echo "alias ..='cd ..'" >> /home/rvx/.bash_aliases && \
  echo "alias e='exit 0'" >> /home/rvx/.bash_aliases

CMD ["bash"]
