# Canny边缘检测{#tutorial_py_canny_cn}

## 目标

在这一章中，我们将学习

- Canny边缘检测的概念
- OpenCV的Canny边缘检测函数：`cv2.Canny()`

## 理论基础

Canny边缘检测是一种流行的边缘检测算法。它是由John F. Canny于1986年开发的。它是一个多阶段算法，我们将学习每个阶段。

- 降噪

  由于边缘检测容易受到图像中的噪声影响，因此首先要用5x5高斯滤波器去除图像中的噪声。我们在前面的章节已经看到了这一点。

- 寻找图像的量度梯度

  用Sobel核在水平和垂直方向对平滑后的图像进行滤波，得到水平方向（$G_x$）和垂直方向（$G_y$）的一阶导数。从这两个图像中，我们可以找到每个像素的边缘梯度和方向如下：
  $$
  Edge\_Gradient \; (G) = \sqrt{G_x^2 + G_y^2} \\
  Angle \; (\theta) = \tan^{-1} \bigg(\frac{G_y}{G_x}\bigg)
  $$
  梯度方向总是垂直于边缘。它被四舍五入为代表垂直，水平和两个对角线方向的四个角度之一。

- 非最大抑制

  在得到梯度幅度和方向后，完成对图像的扫描以去除可能不构成边缘的任何不需要的像素。为此，在每个像素处，检查像素是否是在其梯度方向上的邻域中的局部最大值。看下面的图像：

      ![image](images/nms.jpg)

  ​

  点A在边缘（垂直方向）。梯度方向与边缘垂直。 B点和C点处于梯度方向。所以点A和点B、C比较以检查它是否是一个局部最大值。如果是，则考虑下一阶段，否则它将被压制（置零）。

  总之，你得到的结果是一个有着“薄边缘”的二值图像。

- Hysteresis阈值

  这个阶段决定哪些边缘是真正的边缘，哪些不是边缘。为此，我们需要两个阈值`minVal`和`maxVal`。强度梯度大于`maxVal`的肯定是边缘，低于`minVal`的肯定不是边缘，因此被丢弃。位于这两个阈值之间的像素基于其连接性分为边缘或非边缘。如果它们连接到“确定边缘”的像素，则它们被认为是边缘的一部分。否则，他们也将被丢弃。

  看下面的图片：

  ![image](images/hysteresis.jpg)

  边缘A在maxVal之上，因此被认为是“确定边缘”。虽然边C低于maxVal，但它连接到边A，所以也被认为是有效的边，我们得到了完整的曲线。但边B虽然在minVal以上，与边C的区域相同，但没有连接到任何“确定边缘”，因此被丢弃。所以我们必须仔细选择`minVal`和`maxVal`以得到正确的结果，这十分重要。

  假如边缘是一根长线，这个阶段也能消除小的像素噪声。

  所以我们最终得到的是图像中的强边缘。

## OpenCV中的Canny边缘检测

OpenCV将上述所有内容放在一个函数`cv2.Canny()`中。我们将看到如何使用它。第一个参数是我们的输入图像。第二和第三个参数分别是我们的`minVal`和`maxVal`。

第三个参数是`aperture_size`。是用于查找图像梯度的索贝尔内核的大小。默认情况下，它是3。最后一个参数是`L2gradient`，它指定了求梯度幅度的公式。如果它是`True`，它会使用上面提到的更准确的方程，否则会使用这个函数：$Edge\_Gradient \; (G) = |G_x| + |G_y|$。默认情况下它为False。

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('messi5.jpg',0)
edges = cv2.Canny(img,100,200)
plt.subplot(121),plt.imshow(img,cmap = 'gray')
plt.title('Original Image'), plt.xticks([]), plt.yticks([])
plt.subplot(122),plt.imshow(edges,cmap = 'gray')
plt.title('Edge Image'), plt.xticks([]), plt.yticks([])
plt.show()
```

看下面的结果：

![image](images/canny1.jpg)

## 更多资源

- [Wikipedia](https://zh.wikipedia.org/wiki/Canny算子)上的Canny边缘检测。
- [Canny边缘检测教程](http://dasl.mem.drexel.edu/alumni/bGreen/www.pages.drexel.edu/_weg22/can_tut.html) by Bill Green, 2002。

## 练习

编写一个小应用程序来实现Canny边缘检测，其阈值可以使用两个轨道条来改变。这样，你就可以了解阈值对结果的影响。