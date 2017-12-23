# 在树莓派配置OpenCV-Python{#tutorial_py_setup_in_raspbian_cn}

## 注

原英文文档无此章节。

很多人都喜欢树莓派这样一个卡片电脑，树莓派在嵌入式设备和机器人方面扮演了重要作用，而OpenCV及其Python绑定也能工作在树莓派上。

注意：本教程暂时不会教你如何配置树莓派摄像头！

## 目标

在这个教程中：

- 我们将会学习如何在Raspbian环境下安装OpenCV-Python。下面的步骤在树莓派 3B（raspbian jessie

  ）下通过了测试。

## 从源码编译安装OpenCV

pip上并没有针对树莓派的OpenCV-Python包，故除了从源码编译外无计可施。

下面的依赖基本都是必须的，如果有对其他OpenCV扩展功能的需求（如添加摄像头），请自行安装依赖并修改`CMake`选项。

### 安装依赖

```bash
sudo apt update
sudo apt install g++ cmake python3 python3-dev python3-pip pkg-config
pip3 install numpy
```

### 下载源码包

有两种下载源码包的方法：

- 获得sorceforge上的发行版源码

  ```bash
  # 使用wget下载源码压缩包
  sudo apt install wget unzip
  wget https://nchc.dl.sourceforge.net/project/opencvlibrary/opencv-unix/3.3.1/opencv-3.3.1.zip
  wget https://github.com/opencv/opencv_contrib/archive/3.3.1.zip
  # 解压备用
  unzip opencv-3.3.1.zip
  unzip 3.3.1.zip
  ```

- 从GitHub上拉取最新版本的源码（如果你要为OpenCV贡献代码，你需要选择此项）

  ```bash
  sudo apt install git
  git clone https://github.com/opencv/opencv.git
  git clone https://github.com/opencv/opencv_contrib.git
  ```

### 准备构建

进入下载到的源码文件夹

```bash
cd opencv-3.3.1 # 如果使用的是GitHub上的源码，那文件夹就叫opencv
```

建立一个build文件夹，并进入它

```bash
mkdir build
cd build
```

利用cmake配置安装

请注意../../opencv_contrib-3.3.1/modules这部分要根据你的opencv_contrib文件夹的路径进行调整

```bash
cmake 	-D CMAKE_BUILD_TYPE=RELEASE \
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
```

还有其他许多标志和设置。 留给你进一步探索。

### 构建&安装

```bash
make
sudo make install
```

这样应该就装好了。

注意，编译非常之慢（尤其是最后cv2.cpp的编译，需要数个小时），你也许会想要打开`-j4`等并行编译命令来加速编译，但这对最后cv2.cpp的编译基本没有帮助，而且由于make的缺陷，时常会报错，故不建议开启。

### 测试

打开一个Python控制台，试试看：

```python
>>> import cv2
>>> cv2.__version__
```

如果没有出现错误，而且正确的打印出了你安装的OpenCV版本号，那恭喜你成功了！

## 练习

- 在你的树莓派上从源码构建安装OpenCV-Python。



