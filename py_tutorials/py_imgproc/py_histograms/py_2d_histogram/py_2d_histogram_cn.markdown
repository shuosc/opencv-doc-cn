# 二维直方图{#tutorial_py_2d_histogram_cn}

## 目标

在本章中，我们将学习查找和绘制二维直方图。这将在未来的章节中有所帮助。

## 介绍

在第一篇文章中，我们计算和绘制了一维直方图。它是一维的，因为我们只考虑一个特征，即像素的灰度强度值。但是在二维直方图中，您会考虑两个特征。通常用于查找颜色直方图，此时两个特征是每个像素的色调和饱和度值。

有一个python示例（samples / python / color_histogram.py）已经用于展示如何查找颜色直方图。我们将尝试了解如何创建这样一个颜色直方图，这将有助于理解进一步的主题，如直方图反向投影。

## OpenCV中的2D直方图

这很简单，同样使用函数`cv2.calcHist()`进行计算。对于颜色直方图，我们需要将图像从BGR转换为HSV。 （请记住，对于一维直方图，我们从BGR转换为灰度）。对于2D直方图，其参数将被修改如下：

- `channels = [0,1]`，因为我们需要处理H和S平面。
- `bins = [180,256]`，180 for H平面，256 for S平面。
- `range = [0,180,0,256]`，色调值介于0和180之间，饱和度介于0和
    256之间。

现在看看下面的代码：

```python
import cv2
import numpy as np

img = cv2.imread('home.jpg')
hsv = cv2.cvtColor(img,cv2.COLOR_BGR2HSV)
hist = cv2.calcHist([hsv], [0, 1], None, [180, 256], [0, 180, 0, 256])
```

就是这样。

## Numpy中的二维直方图

Numpy还为此提供了一个专用函数：`np.histogram2d()`。 （请记住，对于一维直方图，我们使用`np.histogram()`）。

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('home.jpg')
hsv = cv2.cvtColor(img,cv2.COLOR_BGR2HSV)
hist, xbins, ybins = np.histogram2d(h.ravel(),s.ravel(),[180,256],[[0,180],[0,256]])
```



第一个参数是H平面，第二个是S平面，第三个是bin的数量，第四个是他们的范围。

现在我们可以来看看如何绘制这个颜色直方图。

## 绘制二维直方图

###方法1：使用`cv2.imshow()`

我们得到的结果是一个尺寸为180x256的二维数组。所以我们可以使用`cv2.imshow()`函数正常显示它们。这将是一个灰度图像，它不会给出太多的颜色信息，除非你知道不同颜色的色调值。

### 方法2：使用Matplotlib

我们可以使用`matplotlib.pyplot.imshow()`函数来绘制不同颜色贴图的二维直方图。它给了我们关于不同像素密度的更多信息。但是，这也不能让我们一眼看出是什么颜色，除非你知道不同颜色的色调值。不过我更喜欢这种方法。这很简单，更好。

使用此功能时，请记住，插值标志应该是nearest，以获得更好的结果。

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('home.jpg')
hsv = cv2.cvtColor(img,cv2.COLOR_BGR2HSV)
hist = cv2.calcHist( [hsv], [0, 1], None, [180, 256], [0, 180, 0, 256] )
plt.imshow(hist,interpolation = 'nearest')
plt.show()
```

以下是输入图像及其颜色直方图。 X轴显示S值，Y轴显示色调。

![image](images/2dhist_matplotlib.jpg)

在直方图中，您可以看到H = 100和S = 200附近的一些高值。它对应于天空的蓝色。同样，在H = 25和S = 100附近可以看到另一个峰值。它对应于宫殿的黄色。您可以使用任何图像编辑工具（如GIMP）来验证它。

### 方法3：OpenCV示例风格

在OpenCV-Python示例（samples/python/color_histogram.py）中有一个用于颜色直方图的示例代码。

如果你运行代码，你可以看到直方图也显示相应的颜色。或者只是输出一个颜色编码的直方图。其结果是非常好的（尽管你需要添加额外的线）。

在该代码中，作者在HSV中创建了一个色彩图。然后转换成BGR。得到的直方图图像与该颜色图相乘。他还使用了一些预处理步骤去除小的孤立像素，从而得到一个很好的直方图。

我把运行代码，分析它，并自己hack一下的任务留给读者。下面是与上面相同的图像的代码的输出：

![image](images/2dhist_opencv.jpg)

你可以在直方图中清楚地看到有什么颜色存在，蓝色在那里，黄色在那里，还有一些白色（因为途中有一个棋盘图案）在那里。Nice！