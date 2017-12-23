# 在Debian（Ubuntu）中配置OpenCV-Python{#tutorial_py_setup_in_debian_cn}

## 注

原英文文档无此章节。

Debian及由其派生出的Ubuntu作为普及度较广的Linux发行版之一，应该有一篇针对Debian家族的OpenCV-Python环境配置的文档。

本文档采用OpenCV 3.3+Python 3的配置，因为Python3是Python的未来，教程其他部分中有少部分代码只能用于Python 2（虽然将其改成合法Python 3代码十分方便），请使用者注意。

如果你坚持要使用Python 2，只需将CMake这里的选项稍作修改即可。

## 目标

在这个教程中：

- 我们将会学习如何在Debian（Ubuntu）环境下安装OpenCV-Python。下面的步骤在Ubuntu 17.04和（Docker中的）Debian stretch下通过了测试。

## 直接使用pip安装

由于不同的环境下默认用户是否是root的情况不同，下面的代码中不会添加sudo，请在得到权限不足的错误时自行添加sudo。

首先安装python环境

```python
apt update
apt install python3 python3-pip
```

然后直接

```bash
pip3 install opencv-python
```

简单粗暴

## 从源码编译安装OpenCV

虽然在Debian中利用包管理器等方式安装OpenCV确实可行，但这样可能会出现各种奇怪的支持错误，因此我们下面会讲解如何从源码安装OpenCV。

下面的依赖基本都是必须的，如果有对其他OpenCV扩展功能的需求，请自行安装依赖并修改`CMake`选项。

由于不同的环境下默认用户是否是root的情况不同，下面的代码中不会添加sudo，请在得到权限不足的错误时自行添加sudo。

### 安装依赖

```bash
apt update
apt install g++ cmake python3 python3-dev python3-pip pkg-config
pip3 install numpy
```

如果你需要`cv2.imshow()`等GUI功能，需要安装**GTK-dev**，如果你准备通过其他方式绘制图形到屏幕上（如`matplotlib`）或者不需要（又或是不能，如要安装在docker容器中），可以忽略下面这行命令：

```bash
apt install libgtk2.0-dev
```

### 下载源码包

有两种下载源码包的方法：

- 获得sorceforge上的发行版源码

  ```bash
  # 使用wget下载源码压缩包
  apt install wget unzip
  wget https://nchc.dl.sourceforge.net/project/opencvlibrary/opencv-unix/3.3.1/opencv-3.3.1.zip
  wget https://github.com/opencv/opencv_contrib/archive/3.3.1.zip
  # 解压备用
  unzip opencv-3.3.1.zip
  unzip 3.3.1.zip
  ```

- 从GitHub上拉取最新版本的源码（如果你要为OpenCV贡献代码，你需要选择此项）

  ```bash
  apt install git
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

如果你需要基于**GTK**的GUI功能

```bash
cmake -D WITH_GTK=ON ..
```

还有其他许多标志和设置。 留给你进一步探索。

### 构建&安装

```bash
make
make install # （这里需要root权限）
```

这样应该就装好了。

### 测试

打开一个Python控制台，试试看：

```python
>>> import cv2
>>> cv2.__version__
```

如果没有出现错误，而且正确的打印出了你安装的OpenCV版本号，那恭喜你成功了！

![result](image/result.png)

## 更多资源

- 如果你在安装了GTK的GUI支持，但在用`imshow`显示图像时遇到了类似下面这样的问题：

  ```
  /usr/share/themes/Ambiance/gtk-2.0/apps/mate-panel.rc:30: error: invalid string constant "murrine-scrollbar", expected valid string constant
  ```

  那么你可以打开/usr/share/themes/Ambiance/gtk-2.0/apps/mate-panel.rc，找到`murrine-scrollbar`并将其替换为`scrollbar`，即可解决问题。

## 练习

- 在你的Debian（Ubuntu）机器上从源码构建安装OpenCV-Python。



