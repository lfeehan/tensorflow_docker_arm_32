#FROM arm32v7/ubuntu
FROM multiarch/debian-debootstrap:armhf-stretch 

ARG http_proxy $http_proxy
ARG https_proxy $https_proxy


RUN apt-get update
RUN apt-get install -y gnupg2
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends oracle-java8-installer && apt-get clean all

RUN apt-get install -y git zip unzip autoconf make automake libtool curl zlib1g-dev maven swig bzip2 g++

RUN git clone https://github.com/google/protobuf.git

RUN apt-get install -y build-essential

RUN cd protobuf && git checkout tags/v3.2.0

RUN cd protobuf && ./autogen.sh
RUN cd protobuf && ./configure --prefix=/usr
RUN cd protobuf && make -j 4
RUN cd protobuf && make install
ADD maven_proxy.xml /root/.m2/settings.xml
RUN cd protobuf/java && mvn package
RUN git clone https://github.com/bazelbuild/bazel.git
RUN cd bazel && git checkout tags/0.1.0
RUN cp /usr/bin/protoc /bazel/third_party/protobuf/protoc-linux-arm32.exe
RUN cp /protobuf/java/core/target/protobuf-java-3.2.0.jar /bazel/third_party/protobuf/protobuf-java-3.2.0.jar
RUN cd /bazel && ./compile.sh || true
RUN cp /bazel/output/bazel /usr/local/bin

#RUN git clone --recurse-submodules https://github.com/tensorflow/tensorflow.git tensorflows

RUN wget https://github.com/tensorflow/tensorflow/archive/v1.13.2.tar.gz && tar xvzf v1.13.2.tar.gz
RUN apt-get install -y python-numpy swig python-dev

####
# This section is for cuda / GPU compilation & is incomplete
#RUN cd tensorflow-1.13.2 && grep -Rl "lib64"| xargs sed -i 's/lib64/lib/g' && grep -Rl "so.9.0"| xargs sed -i 's/so\.9\.0/so\.6\.5/g'
#####


