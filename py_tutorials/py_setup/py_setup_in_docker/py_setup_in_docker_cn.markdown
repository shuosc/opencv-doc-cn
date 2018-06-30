# 在Docker中安装OpenCV-Python{#tutorial_py_setup_in_docker_cn}

## 注

英文文档无此章节

## 目标

在这个教程中：

- 我们将会学习如何在Docker中安装OpenCV-Python。

## 直接使用pip3安装

你可以使用下面的Dockerfile

```dockerfile
FROM debian
RUN apt update
RUN apt -y install python3 python3-pip
RUN pip3 install opencv-python
```

## 从源码安装

你可以使用下面的Dockerflie

```dockerfile
FROM debian
RUN apt update
RUN apt -y install g++ cmake python3 python3-dev python3-pip pkg-config
RUN apt -y install wget unzip
RUN pip3 install numpy
RUN mkdir library_src
WORKDIR library_src
RUN wget https://nchc.dl.sourceforge.net/project/opencvlibrary/opencv-unix/3.3.1/opencv-3.3.1.zip
RUN wget https://github.com/opencv/opencv_contrib/archive/3.3.1.zip
RUN unzip opencv-3.3.1.zip
RUN unzip 3.3.1.zip
WORKDIR /library_src/opencv-3.3.1
RUN mkdir build
WORKDIR /library_src/opencv-3.3.1/build
RUN cmake 	-D CMAKE_BUILD_TYPE=RELEASE \
		-D CMAKE_INSTALL_PREFIX=/usr/local \
		-D INSTALL_C_EXAMPLES=OFF \
		-D INSTALL_PYTHON_EXAMPLES=ON \
		-D BUILD_EXAMPLES=OFF \
		-D BUILD_opencv_python3=ON \
		-D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-3.3.1/modules \
		-D BUILD_TESTS=OFF \
		-D BUILD_PERF_TESTS=OFF \
        -D WITH_OPENCL=OFF \
        -D WITH_CUDA=OFF \
        -D BUILD_opencv_gpu=OFF \
        -D BUILD_opencv_gpuarithm=OFF \
        -D BUILD_opencv_gpubgsegm=OFF \
        -D BUILD_opencv_gpucodec=OFF \
        -D BUILD_opencv_gpufeatures2d=OFF \
        -D BUILD_opencv_gpufilters=OFF \
        -D BUILD_opencv_gpuimgproc=OFF \
        -D BUILD_opencv_gpulegacy=OFF \
        -D BUILD_opencv_gpuoptflow=OFF \
        -D BUILD_opencv_gpustereo=OFF \
        -D BUILD_opencv_gpuwarping=OFF ..
RUN make
RUN make install
WORKDIR /
RUN rm -rf ./library_src
```

值得注意的是，使用Docker代表了你放弃了所有GUI功能！

## 练习

- 构建一个配置好OpenCV-Python环境的Docker容器