# 霍夫直线变换{#tutorial_py_houghlines}

## 目标

在这一章当中，

- 我们将理解霍夫变换的概念。
- 我们将看到如何使用它来检测图像中的线条。
- 我们将看到以下函数：`cv2.HoughLines()`，`cv2.HoughLinesP()`

## 理论基础

霍夫变换是一种用来检测形状的流行的技术，如果你能以数学形式来表示这种形状的话。它可以检测到形状，即使它被破坏或扭曲了一点。我们将看到它是如何检测出一条线。

一条线可以表示为$y = mx+c$，或以参数方程表示，$\rho = x \cos \theta + y \sin \theta$其中$\rho$是从原点到线的垂直距离，$\theta$是这根直线与水平轴所形成的角度，角度是逆时针测量的（这个方向随您如何表示坐标系而变化，上面说的这个表示方法在OpenCV中使用）。检查下面的图像：

![image](images/houghlines1.svg)

所以如果这条线在原点以下经过，它将有一个正的$\rho$和一个小于180的角度。如果它在原点以上，这里不是取大于180的角度，而是仍然取一个小于180的角度，但$\rho$取负值。垂直线是0度，水平线是90度。

现在让我们来看看霍夫变换是如何工作的。任何一条线都可以用这两个值来表示$(\rho, \theta)$。所以首先创建一个二维数组或者说累加器（来保存这两个参数的值），并将其设置为0。让行表示$\rho$，而列表示$\theta$。数组的大小取决于你需要的精度。假设你想要角度的准确度是1度，你将需要180列。对于$\rho$，可能的最大距离是图像的对角线长度。因此，以精度为一个像素为例，行数可以是图像的对角线长度。

考虑在水平线中间的100x100图像。看线上的第一点。你知道它的$(x,y)$值。现在在行方程中，把值$\theta = 0,1,2，…，180$带入，并检查你得到的$\rho$。对于每个$(\rho,\theta)$对，您在我们的累加器中的相应$(\rho,\theta)$单元格中将值递增1。所以现在在累加器中，单元$(50,90)= 1$。

现在看线上的第二点。像上面一样做。递增对应于$(\rho,\theta)$的单元格中的值。这一次，单元格$(50,90)= 2$。你实际上做的是对$(\rho,\theta)$值投票。继续对每一个点应用这个操作。在每个点上，单元格(50,90)的票数都会递增，而其他单元格可能会被投票或者不投票。这样，最后，单元（50,90）将获得最多的选票。因此，如果您搜索累加器获得最大的选票，您将得到值（50,90），即在该图像中距离原点50度，角度90度处有一条线。它在下面的动画中很好地显示（图片提供者：[Amos Storkey](http://homepages.inf.ed.ac.uk/amos/hough.html)）

![](images/houghlinesdemo.gif)

这就是霍夫变换对线条的工作原理。这很简单，也许你可以使用Numpy自己实现它。以下是显示累加器的图像。某些位置的亮点表示它们是图像中可能线条的参数。 （图片提供者： [维基百科](http://en.wikipedia.org/wiki/Hough_transform)）

![](images/houghlines2.jpg)

## OpenCV中的霍夫变换

上面解释的一切都封装在OpenCV函数`cv2.HoughLines()`)中。它只是返回一个数组的$(\rho, \theta)$。 $\rho$以像素为单位进行测量，$\theta$以弧度测量。第一个参数是输入图像，应该是一个二值图像，所以在应用霍夫变换之前应用阈值或者使用canny边缘检测。第二和第三个参数分别是$\rho$和$\theta$精度。第四个参数是阈值，这意味着被视为一条线所需要的最低的投票。记住，得票数取决于线上的点数。所以它代表了应该检测到的线的最小长度。

@include hough_line_transform.py

下面是结果：

![image](images/houghlines3.jpg)

## 概率霍夫变换

在霍夫变换中，即使对于有两个参数的行，也可以看到很多计算。概率霍夫变换是我们看到的霍夫变换的一个优化。它没有考虑到所有的要点。相反，它只需要一个随机子集，足以进行在线检测。只是我们必须降低门槛。请参阅下面的图像，比较霍夫空间中的霍夫变换和概率霍夫变换。 （图片提供者：[Franck Bettinger的主页](http://phdfb1.free.fr/robot/mscthesis/node14.html)）

![image](images/houghlines4.png)

OpenCV的实现是基于Robust Detection of Lines Using the Progressive Probabilistic Hough Transform by Matas, J. and Galambos, C. and Kittler, J.V. @cite Matas00.。使用的函数是`cv2.HoughLinesP()`。它有两个新的参数。

- **minLineLength** - 行的最小长度。比这更短的线段被拒绝。
- **maxLineGap** - 线段之间允许的最大间隔来处理它们

最好事情的是，它直接返回行的两个端点。 在前面的例子中，你只有线的参数，你必须找到所有的点。 在这里，一切都是直接和简单的。

@include probabilistic_hough_line_transform.py

看下面的结果：

![image](images/houghlines5.jpg)

## 更多资源

- [Wikipedia上的霍夫变换](https://zh.wikipedia.org/wiki/霍夫变换)