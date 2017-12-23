# 轮廓：入门{#tutorial_py_contours_begin_cn}

## 目标

- 了解轮廓是什么。
- 学习找出轮廓，绘制轮廓等
- 你会看到这些函数：`cv2.findContours()`，`cv2.drawContours()`

## 什么是轮廓？

轮廓可以简单地解释为连接所有连续点（沿着边界）的曲线，其具有相同的颜色或强度。轮廓是形状分析和物体检测与识别的有用工具。

- 为了更好的准确性，请使用二值图像。因此，在寻找轮廓之前，要先进行图像二值化或Canny边缘检测。
- 自OpenCV 3.2以来，`findContours()`不再修改源图像，而是返回一个修改后的图像作为三个返回值中的第一个。
- 在OpenCV中，查找轮廓是从黑色背景中找到白色物体。所以请记住，要找到的对象应该是白色的，背景应该是黑色的。

我们来看看如何找到一个二值图像的轮廓：

```python
import numpy as np

import cv2

im = cv2.imread('test.jpg')

imgray = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)

ret, thresh = cv2.threshold(imgray, 127, 255, 0)

im2, contours, hierarchy = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
```

看，`cv2.findContours()`函数有三个参数，第一个是源图像，第二个是轮廓检索模式，第三个是轮廓近似法。它输出修改后的图像，轮廓和层次结构。轮廓是图像中所有轮廓的Python列表。每个单独的轮廓是对象的边界点的(x,y)坐标的Numpy数组。

我们稍后将详细讨论第二和第三个参数以及关于层次结构的细节。在那之前，在代码示例中赋予它们的值对于所有图像都可以正常工作。

## 如何绘制轮廓？

要绘制轮廓，使用`cv2.drawContours`函数。它也可以用来绘制任何形状，只要你有它的边界点。它的第一个参数是源图像，第二个参数是应该作为Python列表传递的轮廓，第三个参数是轮廓的索引（绘制个别轮廓时有用，要绘制所有轮廓，可以传入-1），其余参数是颜色，线条宽度等等。

- 在图像中绘制所有的轮廓：

  ```python
  cv2.drawContours(img, contours, -1, (0,255,0), 3)
  ```

- 绘制一个单独的轮廓，比如第四个轮廓：

  ```python
  cv2.drawContours(img, contours, 3, (0,255,0), 3)
  ```

- 但大部分情况下，可以用下面的方法：

  ```python
  cnt = contours[4]
  cv2.drawContours(img, [cnt], 0, (0,255,0), 3)
  ```

  最后两种方法是相同的，但是当你往下看时，你会看到最后一个更有用。

## 轮廓近似法

这是`cv2.findContours`函数的第三个参数。它究竟是什么？

如上所述，我们知道了轮廓是一个相同强度的形状的边界。它存储形状边界的(x,y)坐标。但它是否存储所有的坐标？这是通过这个轮廓近似方法来指定的。

如果你传递了`cv2.CHAIN_APPROX_NONE`，所有的边界点都会被存储。但实际上我们需要所有的边界点吗？例如，你找到了一条直线的轮廓。你需要线上的所有点来代表那条线吗？不，我们只需要该线的两个端点。这是`cv2.CHAIN_APPROX_SIMPLE`所做的。它删除所有冗余点并压缩轮廓，从而节省内存。

下面的矩形图像显示了这种技术。只需在轮廓数组中的所有坐标上绘制一个圆圈（用蓝色绘制）即可。第一张图片显示了我用`cv2.CHAIN_APPROX_NONE`（734个点）得到的点，第二张图显示了用`cv2.CHAIN_APPROX_SIMPLE`（只有4个点）的图片。看，它节省了多少内存！

![image](images/none.jpg)