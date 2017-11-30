# 介绍SIFT（尺度不变特征转换）[^1]{#tutorial_py_sift_intro_cn}

## 目标

在这一章中：

- 我们将学习SIFT算法的概念。
- 我们将学习找到SIFT关键点和描述符。

## 理论基础

在前几章中，我们看到了一些像Harris这样的角点检测器。它们是旋转不变的，这意味着，即使图像旋转了，我们也可以找到相同的角点。 这是显而易见的，因为边角在图像旋转后也是边角。 但是缩放呢？ 如果图像缩放，边角可能不再是一个边角。 例如，请看下面的简单图片。  当放大到同一个窗口时，小窗口内的小图像中的一个角落是平滑的。 所以Harris角点检测不是比例不变的。

![image](images/sift_scale_invariant.jpg)

因此，在2004年，不列颠哥伦比亚大学的 D.Lowe 在他的论文中提出了一种新的算法：尺度不变特征变换（SIFT），《Distinctive Image Features from Scale-Invariant Keypoints》[^2]，这个算法提取关键点并计算其描述符。*（这篇论文很容易理解，并被认为是在SIFT方面最好的资料，所以这个解释只是论文的一个简短摘要）*。

SIFT算法主要涉及四个步骤。 我们会一一看到他们。

1. 尺度空间极值检测

   从上图中可以看出，我们不能用同一个窗口来检测不同尺度的关键点。 小的边角也许可以。 但要检测更大的边角，我们需要更大的窗口。

   为此，需要使用缩放空间过滤。 这个过程中，Laplacian of Gaussian is found for the image with various $\sigma$ values。 LoG作为一个斑点检测器，它可以检测由于$\sigma$中的变化而产生的各种大小的斑点。 简而言之，$\sigma$在此充当了一个缩放参数。 例如，在上面的图像中，低$\sigma$的高斯核为小边角赋值较高，而高$\sigma$的高斯核适合较大的角。 所以，我们可以找到跨越尺度和空间的局部最大值，它给出了一个$(x,y,\sigma)$值的列表，这意味着在$(x,y)$处有一个潜在比例为$\sigma$的关键点。

   但是LoG性能开销比较大，所以SIFT算法使用LoG的近似：高斯滤波器的差值。 高斯滤波器差值就是高斯模糊过的有两个不同$\sigma$的同一幅图片的差值，设这两个$\sigma$值为$\sigma$和$k\sigma$。这个过程对每组不同的图像金字塔中的“八度”执行。

    下面的图像展示了它的过程：

   ![image](images/sift_dog.jpg)

   一旦找到这个DoG，就会在空间和规模上搜索图像的局部极值。 例如，图像中的一个像素与其8个邻居以及下一个尺度的9个像素和先前尺度的9个像素进行比较。 如果是局部极值，这就是一个潜在的关键点。 这基本上意味着在这个尺度上关键点是最好的。 如下图所示：

   ![image](images/sift_local_extrema.jpg)

   关于不同的参数，论文给出了一些经验数据，可以概括为：八度数= 4，比例级数= 5，初始$\sigma = 1.6 $，$k = \sqrt {2} $等作为最佳值。

2. 关键点定位

    一旦找到潜在的关键点位置，就必须对其进行改进以获得更准确的结果。

    他们使用尺度空间的泰勒级数展开来获得更精确的极值位置，如果这个极值的强度小于阈值（按照论文，这个阈值是0.03），则被丢弃。 这个阈值在OpenCV中被称为`contrastThreshold`。

    DoG对边缘的响应更高，所以边缘也需要去除。 为此，使用了与Harris角点检测器相似的概念。 他们用一个2×2的Hessian矩阵（$H$）来计算主要曲率。 我们从Harris角点检测器知道，对于边缘来说，一个特征值比另一个大。 所以在这里他们使用了一个简单的函数，如果这个比值大于一个在OpenCV中被称为	`edgeThreshold`的阈值，那么这个关键点被丢弃。 在论文中这个阈值是10。

    所以它消除了任何低对比度的关键点和边缘关键点，剩下的就是强的兴趣点。

3. 方向分配

    现在为每个关键点分配一个方向，以实现图像旋转的不变性。 根据规模在关键位置周围采取邻里关系，并计算该地区的梯度大小和方向。 创建一个方向直方图，其中36个方框覆盖360度。 它是通过梯度幅度和高斯加权循环窗口加权的， $\sigma$等于关键点的1.5倍。 取直方图中的最高峰值，并且任何高于80％的峰值也被认为是计算方向。 它创建具有相同位置和规模的关键点，但方向不同。 它有助于匹配的稳定性。

4. 关键点描述符

    现在创建关键点描述符。 关键点附近有一个16x16的块。 它分为16个4x4大小的子块。 对于每个子块，创建8个方向直方图。

    所以总共有128个二进制值可用。 它被表示为形成关键点描述符的向量。 除此之外，还采取了多种措施来实现对光照变化，旋转等的鲁棒性。

5. 关键点匹配
    两幅图像之间的关键点通过识别最近的邻居来匹配。 但在某些情况下，第二个最接近的匹配可能非常接近第一个。 这可能是由于噪音或其他原因。 在这种情况下，取最近距离与第二近距离的比率。 如果它大于0.8，则被丢弃。 根据论文，这排除了大约90％的错误匹配，而只会丢弃5％的正确匹配。

所以这就是SIFT算法的一个摘要。为了获取更多信息和更好的理解，我们强烈建议阅读论文原文。记住这个算法有专利保护，所以这个算法被包含在[the opencv contrib repo](https://github.com/opencv/opencv_contrib)中。

## OpenCV中的SIFT

现在让我们来看看OpenCV中的SIFT功能。 我们从检测出关键点并绘制它们开始。 首先，我们必须构建一个SIFT对象。 我们可以传递不同的参数给它，这些参数是可选的，并且在文档中有很好的解释。

```python
import cv2
import numpy as np
img = cv2.imread('home.jpg')
gray= cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
sift = cv2.xfeatures2d.SIFT_create()
kp = sift.detect(gray,None)
img=cv2.drawKeypoints(gray,kp,img)
cv2.imwrite('sift_keypoints.jpg',img)
```

`sift.detect()`函数在图像中找到关键点。 如果您只想搜索图像的一部分，则可以传递mask。 每个关键点是一个特殊的结构体，它具有许多属性，如它的$(x,y)$坐标，有意义的邻域的大小，其方向的角度，指定关键点的强度等。

OpenCV还提供`cv2.drawKeyPoints()`函数，用于绘制关键点位置的小圆圈。 如果你传递一个标志`cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS`给它，它将绘制一个大小为keypoint的圆，它甚至会显示它的方向。 看下面的例子。

```python
img=cv2.drawKeypoints(gray,kp,img,flags=cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)

cv2.imwrite('sift_keypoints.jpg',img)
```

看下面的结果：

![image](images/sift_keypoints.jpg)

现在我们来计算描述符，OpenCV提供了两种方法。

- 既然已经找到了关键点，你可以调用`sift.compute()`来计算我们找到的关键点的描述符。 例如：`kp,des = sift.compute(gray,kp)`
- 如果没有找到关键点，可以用函数`sift.detectAndCompute()`直接找到关键点和描述符。

我们来看一下第二种方法：

```python
sift = cv2.xfeatures2d.SIFT_create()
kp, des = sift.detectAndCompute(gray,None)
```

这里`kp` 是一个关键点的列表， `des` 是一个shape为$Number\_of\_Keypoints \times 128$的numpy array。

我们得到了关键点，描述符等等。现在我们要看看如何匹配不同图像中的关键点。

我们将在接下来的章节中学习这些。



[^1]: https://zh.wikipedia.org/wiki/缩放不变特征转换
[^2]: http://citeseer.ist.psu.edu/lowe04distinctive.html

 