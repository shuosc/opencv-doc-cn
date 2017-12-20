# 在Fedora环境下安装OpenCV-Python{#tutorial_py_setup_in_fedora_cn}

## 目标

在这个教程中：

- 我们将会学习如何在Fedora系统下安装OpenCV-Python。下面的步骤在Fedora 18 (64-bit) 和 Fedora 19 (32-bit) 下通过了测试。

## 介绍

OpenCV-Python可以通过两种方式安装到Fedora上，
1）安装Fedora软件包库中的预编译二进制文件
2）从源代码编译
在这一教程中，我们将展示这两者。

另一个重要的事是所需的依赖库。 OpenCV-Python只需要Numpy（还有些其他的非必须依赖，我们将在后面看到）。 在本教程中，我们也会使用Matplotlib进行了一些简单而又很好用的图片显示（我觉得这比OpenCV自带的图片显示功能相比好多了）。 Matplotlib是可选的，但我们强烈建议使用这个库。 同样，我们也会用到IPython，一个交互式的Python终端，我们也强烈推荐它。

##从Fedora软件包库中的预编译二进制文件中安装OpenCV-Python

在终端下使用下面的命令安装下面所有的包（需要root）：

```sh
$ yum install numpy opencv*
```

打开Python IDLE （或 IPython）并在Python控制台中输入：

```python
>>> import cv2
>>> print(cv2.__version__)
```

如果输出被顺利的打印在屏幕上，并且没有报错的话，那么祝贺你，安装成功了！

这种安装方式相当简单，但是有一个问题，yum的仓库里也许并不总是包含最新的OpenCV版本。比如，在编写这个教程时，yum仓库中的OpenCV版本是2.4.5，但最新的OpenCV版本是2.4.6。对于Python API，最新版本将总是包含更好的支持。 另外，根据驱动程序，ffmpeg，gstreamer软件包等的不同，可能会出现相机支持，视频播放等问题。

所以我个人偏好下一个方法，就是从源码编译安装OpenCV。而且如果未来某一时刻你想为OpenCV项目做些贡献，那你就一定需要这么做。

## 从源码编译安装OpenCV

从源码编译起初可能看起来有点复杂，但是一旦你成功了，也就会觉得没有什么复杂的了。

首先，我们将安装一些依赖项。 有些是必要的，有些是可选的。如果你不想要一些可选的依赖关系，你可以不理睬它们。

## 强制性依赖

我们需要**CMake**来配置安装，**GCC**来编译代码，**Python-devel**和**Numpy**来创建Python扩展等等。

```sh
yum install cmake
yum install python-devel numpy
yum install gcc gcc-c++
```

接下来我们需要**GTK**来支持GUI功能、照相机支持(libdc1394, libv4l)、动画媒体支持(ffmpeg, gstreamer)等等。

```sh
yum install gtk2-devel
yum install libdc1394-devel
yum install libv4l-devel
yum install ffmpeg-devel
yum install gstreamer-plugins-base-devel
```

## 可选依赖

上面的依赖关系足以让你在你的的fedora机器上安装OpenCV。 但根据您的要求，您可能需要一些额外的依赖关系。 下面给出了这样的可选依赖项的列表。 你可以不理睬它或安装它，这由你自己决定 :)

OpenCV支持PNG，JPEG，JPEG2000，TIFF，WebP等图像格式，但这些支持可能有点旧了。 如果你想获得最新的库，你可以安装这些格式的开发文件。

```sh
yum install libpng-devel
yum install libjpeg-turbo-devel
yum install jasper-devel
yum install openexr-devel
yum install libtiff-devel
yum install libwebp-devel
```

**英特尔的线程构建模块**（TBB）可以将一些OpenCV函数并行化。 但是如果你想启用它，你需要先安装TBB。 （如果你要开启TBB，那么在使用CMake配置安装时，不要忘记传递-D WITH_TBB = ON。更多细节将在下面描述。）

```
yum install tbb-devel
```

OpenCV使用另一个库**Eigen**来优化数学运算。 所以如果你的系统中安装了Eigen，你可以使用它。 （同样在使用CMake配置安装时，请不要忘记传递-D WITH_EIGEN = ON。更多细节将在下面描述。）

```sh
yum install eigen3-devel
```

如果你想构建文档（是的，你可以创建离线版本HTML格式OpenCV的完整官方文档，并带有完整的搜索功能，以便在有任何问题时不必访问互联网，而且查询相当快！）， 你需要安装Doxygen（一个文档生成工具）。

```sh
yum install doxygen
```

## 下载OpenCV源码包

接下来我们要下载OpenCV。 您可以从[sourceforge 网站](http://sourceforge.net/projects/opencvlibrary/)下载最新版本的OpenCV。 然后解压缩文件。

或者你可以从OpenCV的github仓库下载最新的源代码。 （如果您想为OpenCV做出贡献，请选择此选项，而且这也将始终保持您的OpenCV处于最新状态）。 为此，您需要先安装Git。

```sh
yum install git
git clone https://github.com/opencv/opencv.git
```

它将在主目录（或您指定的目录）中创建一个OpenCV文件夹。 根据您的网络连接，clone可能需要一些时间。

现在打开终端窗口并进入下载的OpenCV文件夹。 创建一个新的build文件夹并进入它。

```sh
mkdir build
cd build
```

## 配置并安装

现在我们安装了所有必需的依赖关系，让我们安装OpenCV。 安装必须使用CMake进行配置。 它指定要安装哪些模块，安装路径，要使用哪些附加库，是否编译文档和示例等。下面的命令通常用于配置（从build文件夹执行）。

```sh
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local ..
```

它指定构建类型为“发布模式”，安装路径为/usr/local。 在每个构建选项前注意-D，并以..结束。 简单来说，用下面的格式：

```sh
cmake -D <flag> ..
```

您可以指定任意多个标志，但每个标志之前都应该有-D。

在本教程中，我们安装了带有TBB和Eigen支持的OpenCV。 我们也将构建离线文档，但是我们不构建性能测试和示例。 我们也禁用了GPU相关模块（因为我们使用OpenCV-Python，我们不需要与GPU相关的模块，这也为我们节省了一些编译时间）。

*（下面的所有命令都可以在一个cmake语句中完成，但是为了更容易理解，这里将其分开。）*

- 开启TBB和Eigen支持

  ```sh
  cmake -D WITH_TBB=ON -D WITH_EIGEN=ON ..
  ```

- 开启离线文档构建，关闭测试和示例

  ```sh
  cmake -D BUILD_DOCS=ON -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF ..
  ```

- 禁用GPU相关的模组

  ```sh
  cmake -D WITH_OPENCL=OFF -D WITH_CUDA=OFF -D BUILD_opencv_gpu=OFF -D BUILD_opencv_gpuarithm=OFF -D BUILD_opencv_gpubgsegm=OFF -D BUILD_opencv_gpucodec=OFF -D BUILD_opencv_gpufeatures2d=OFF -D BUILD_opencv_gpufilters=OFF -D BUILD_opencv_gpuimgproc=OFF -D BUILD_opencv_gpulegacy=OFF -D BUILD_opencv_gpuoptflow=OFF -D BUILD_opencv_gpustereo=OFF -D BUILD_opencv_gpuwarping=OFF ..
  ```

- 设置安装路径和构建类型

  ```sh
  cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local ..
  ```
  每次输入cmake语句时，都会打印出最终的配置设置。 在最后的设置中，确保以下字段都被填充好了（下面是我得到的配置的一些重要部分）。 这些字段也应在您的系统中适当填写。 否则就会发生一些问题。 所以请检查您是否正确执行了上述步骤。

  ```sh
  --   GUI:
  --     GTK+ 2.x:                    YES (ver 2.24.19)
  --     GThread :                    YES (ver 2.36.3)
  --   Video I/O:
  --     DC1394 2.x:                  YES (ver 2.2.0)
  --     FFMPEG:                      YES
  --       codec:                     YES (ver 54.92.100)
  --       format:                    YES (ver 54.63.104)
  --       util:                      YES (ver 52.18.100)
  --       swscale:                   YES (ver 2.2.100)
  --       gentoo-style:              YES
  --     GStreamer:
  --       base:                      YES (ver 0.10.36)
  --       video:                     YES (ver 0.10.36)
  --       app:                       YES (ver 0.10.36)
  --       riff:                      YES (ver 0.10.36)
  --       pbutils:                   YES (ver 0.10.36)
  --     V4L/V4L2:                    Using libv4l (ver 1.0.0)
  --   Other third-party libraries:
  --     Use Eigen:                   YES (ver 3.1.4)
  --     Use TBB:                     YES (ver 4.0 interface 6004)
  --   Python:
  --     Interpreter:                 /usr/bin/python2 (ver 2.7.5)
  --     Libraries:                   /lib/libpython2.7.so (ver 2.7.5)
  --     numpy:                       /usr/lib/python2.7/site-packages/numpy/core/include (ver 1.7.1)
  --     packages path:               lib/python2.7/site-packages
  ```

  还有其他许多标志和设置。 留给你进一步探索。

  现在使用make命令构建文件，并使用make install命令进行安装。 make install应该以root身份执行。

  ```sh
  make
  su make install
  ```

  安装结束了，所有文件都安装在/usr/local/文件夹中。但是要使用它，你的Python应该能够找到OpenCV模块。你有两个选择。

  - 将模块移动到Python路径中的任何文件夹：

    可以通过在Python控制台中输入`import sys; print(sys.path)`找到Python路径。它会打印出很多个路径。 将/usr/local/lib/python2.7/site-packages/cv2.so移动到这个文件夹中的任何一个。 例如:

    ```sh
    su mv /usr/local/lib/python2.7/site-packages/cv2.so /usr/lib/python2.7/site-packages
    ```

    但每次你重新安装OpenCV时你都需要这样做。

  - 将/usr/local/lib/python2.7/site-packages加入PYTHON_PATH：

    只需要这样做一次。只需打开~/.bashrc然后增加下面这一行，然后登出再登录：

    ```sh
    export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python2.7/site-packages
    ```

    这样OpenCV就安装好了。打开一个Python控制台然后试试看`import cv2`。

    要构建文档，只需要输入下面的命令：

    ```sh
    make doxygen
    ```

    然后打开opencv/build/doc/doxygen/html/index.html，并在浏览器内给它加上一个书签即可。

    ## 练习

    在你的Fedora机器上从源码构建安装OpenCV-Python。