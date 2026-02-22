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

# 4. Install Verible
RUN curl -fsSL https://github.com/chipsalliance/verible/releases/download/v0.0-4051-g9fdb4057/verible-v0.0-4051-g9fdb4057-linux-static-x86_64.tar.gz | tar -xz -C /tmp && \
  cp /tmp/verible-v0.0-4051-g9fdb4057/bin/* /usr/local/bin/ && \
  rm -rf /tmp/verible-v0.0-4051-g9fdb4057

# 5. Install the RISC-V GNU Toolchain
RUN git clone https://github.com/riscv/riscv-gnu-toolchain /tmp/riscv-gnu-toolchain && \
  cd /tmp/riscv-gnu-toolchain && \
  ./configure --with-arch=rv32izicsr --with-abi=ilp32 --prefix=/usr/local && \
  make -j$(nproc) && make install && \
  rm -rf /tmp/riscv-gnu-toolchain

# 6. Install Universal Ctags
RUN git clone https://github.com/universal-ctags/ctags.git /tmp/ctags && \
  cd /tmp/ctags && ./autogen.sh && ./configure && make -j$(nproc) && make install && \
  rm -rf /tmp/ctags

# 7. Customize bash prompt
RUN echo "PS1='\[\033[01;32m\]\u@\h \[\033[01;34m\]\w\[\033[01;33m\]\$(__git_ps1 \" (%s)\")\[\033[00m\] \$ '" >> /home/rvx/.bashrc

# 8. Install RISC-V Spike Simulator
RUN git clone https://github.com/riscv-software-src/riscv-isa-sim.git /tmp/riscv-isa-sim && \
  cd /tmp/riscv-isa-sim && mkdir build && cd build && \
  ../configure --prefix=/usr/local && \
  make -j$(nproc) && make install && \
  rm -rf /tmp/riscv-isa-sim

# 9. Install Tig
RUN apt-get update && apt-get install -y --no-install-recommends libncursesw5-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/* && \
  curl -fsSL https://github.com/jonas/tig/releases/download/tig-2.5.4/tig-2.5.4.tar.gz | tar -xz -C /tmp && \
  cd /tmp/tig-2.5.4 && make prefix=/usr/local && make install prefix=/usr/local && \
  rm -rf /tmp/tig-2.5.4

USER rvx
WORKDIR /home/rvx

# 10. Add bash aliases
RUN echo "alias ll='ls -la'" >> /home/rvx/.bash_aliases && \
  echo "alias ..='cd ..'" >> /home/rvx/.bash_aliases && \
  echo "alias e='exit 0'" >> /home/rvx/.bash_aliases

CMD ["bash"]
