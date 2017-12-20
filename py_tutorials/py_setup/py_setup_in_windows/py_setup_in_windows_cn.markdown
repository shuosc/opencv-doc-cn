# 在Windows下安装OpenCV-Python{#tutorial_py_setup_in_windows_cn}

## 目标

在这个教程中：

- 我们将学习在Windows操作系统下配置OpenCV-Python开发环境

下面的步骤在Visual Studio 2010和Visual Studio 2012的Windows 7-64位机器上通过了测试。

屏幕截图显示的是使用VS2012的运行结果。

## 从预编译的二进制包安装

下面的Python包需要被下载并安装到它们的默认位置。

- [Python-2.7.x](http://www.python.org/ftp/python/2.7.13/python-2.7.13.msi).
- [Numpy](https://sourceforge.net/projects/numpy/files/NumPy/1.10.2/numpy-1.10.2-win32-superpack-python2.7.exe/download).
- [Matplotlib](https://sourceforge.net/projects/matplotlib/files/matplotlib/matplotlib-1.5.0/windows/matplotlib-1.5.0.win32-py2.7.exe/download)（Matplotlib是可选的，但是我们推荐安装它，因为我们在教程中大量使用了这个库）

将所有这些包安装到它们默认的位置上，Python将会被安装到C:/Python27/。

在安装完成后，打开Python IDLE，输入`import numpy`来确定Numpy工作正常。

从[sourceforge 网站](http://sourceforge.net/projects/opencvlibrary/files/opencv-win/2.4.6/OpenCV-2.4.6.0.exe/download)下载最新的OpenCV发布版本，并双击解压它。

进入opencv/build/python/2.7文件夹。

将cv2.pyd复制到C:/Python27/lib/site-packages。

打开Python IDLE并输入下面的代码：

```python
>>> import cv2
>>> print( cv2.__version__ )
```

如果输出被顺利地打印在屏幕上，并且没有报错的话，那么祝贺你，安装成功了！

## 从源码构建OpenCV

下载安装Visual Studio 和 CMake。

- [Visual Studio 2012](http://go.microsoft.com/?linkid=9816768)
- [CMake](http://www.cmake.org/files/v2.8/cmake-2.8.11.2-win32-x86.exe)

下载必要的Python包，并安装到默认位置：

- [Python 2.7.x](http://python.org/ftp/python/2.7.5/python-2.7.5.msi)
- [Numpy](http://sourceforge.net/projects/numpy/files/NumPy/1.7.1/numpy-1.7.1-win32-superpack-python2.7.exe/download)
- [Matplotlib](https://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-1.3.0/matplotlib-1.3.0.win32-py2.7.exe)（Matplotlib是可选的，但是我们推荐安装它，因为我们在教程中大量使用了这个库）

我们将使用Python包的32位二进制文件。 但如果你想使用OpenCV for x64，则需要安装Python包的64位二进制文件。 问题是Numpy官方没有提供预编译的64位二进制文件。 你必须自己构建它。 为此，你必须使用用于构建Python的相同编译器。 当你启动Python IDLE时，它会显示编译器细节。 你可以[在这里](http://stackoverflow.com/q/2676763/1134940)获取更多信息。因此，您的系统必须具有和编译Python所用的相同的Visual Studio版本，并从源代码构建Numpy。

另一种使用64位Python包的方法是使用现成的Python第三方发行版，[Anaconda](http://www.continuum.io/downloads)、[Enthought](https://www.enthought.com/downloads/)等等。它的大小可能会大些，但其中包含所有你需要用到的东西。所有的东西都在一个shell里了。你也可以使用它们的32位版本。

确保Python和Numpy正常工作。

下载OpenCV源码，可以从 [Sourceforge](http://sourceforge.net/projects/opencvlibrary/) (官方发布版)或[Github](https://github.com/opencv/opencv) (最新源码)下载。

解压到一个文件夹opencv并在其中建立一个新的build文件夹。

打开CMake-gui（ *开始 \> 所有程序 \> CMake-gui*）

像下面这样填写（见下图）：

- 点击**Browse Souce…**并定位到opencv文件夹。
- 点击**Browse Build…**并定位到我们创建的build文件夹。
- 点击 **Configure**。

![image](images/Capture1.jpg)

​	它会打开一个新窗口来让你选择编译器，选择合适的编译器（这里是Visual Studio 11）并点击**Finish**。

![image](images/Capture2.png)

- 等待analysis过程结束

- 你可以看到所有的fields都是红的。点击**WITH**展开它。它决定了你需要什么额外的特性。钩上合适的fields。见下图：

  ![image](images/Capture3.png)

- 点击**BUILD**展开他。一开始的一些fields配置了构建方法。见下图：

  ![image](images/Capture5.png)

- 剩下的fields指明了要构建哪些模组。因为GPU模组还没有被OpenCV-Python支持，你可以完全不构建他们来节约编译时间（但如果你需要在其他语言绑定中使用有GPU支持的OpenCV，你可以保留他们）。见下图：

  ![image](images/Capture6.png)

- 展开**ENABLE**，确保**ENABLE_SOLUTION_FOLDERS**没有被勾选（Solution folders并不被Visual Studio Express edition支持）。见下图：

  ![image](images/Capture7.png)

- 确保在**PYTHON**一栏中，一切都被填充好了。（忽略`PYTHON_DEBUG_LIBRARY`）。见下图。

  ![image](images/Capture80.png)

- 最终点击**Generate**按钮。

- 现在进入opencv/build文件夹。你将会发现OpenCV.sln文件。用Visual Studio打开它。

- 将构建模式从**Debug**切换到**Release**。

- 在solution explorer中，右击**Solution** (或 **ALL_BUILD**) 然后构建。这会花上一些时间。

- 右击**INSTALL**然后构建它。现在OpenCV-Python就被安装好了。

- 打开Python IDLE并输入` import cv2`，如果没有错误，那就是安装好了。

我们没有安装TBB，Eigen，Qt，Documentation等其他支持。怎么安装它们这里很难解释。我们很快就会添加一个更详细的视频，或者你可以自己做一些hack和尝试。

## 练习

- 如果你有一台Windows机器，从源代码编译OpenCV。 进行各种hack。 如果遇到任何问题，请来OpenCV论坛提问并解释您的问题。