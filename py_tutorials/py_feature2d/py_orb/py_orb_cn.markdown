# ORB特征描述符(Oriented FAST and Rotated BRIEF) {#tutorial_py_orb_cn}

## 目标

在这一章中，

- 我们将学习ORB的基础

## 理论基础

作为OpenCV爱好者，关于ORB最重要的是它来自“OpenCV实验室”。

这个算法是由Ethan Rublee，Vincent Rabaud，Kurt Konolige和Gary R. Bradski在他们的论文《ORB: An efficient alternative to SIFT or SURF》[^1	]提出。正如标题所说，这是一个在计算成本，匹配性能和，最重要的，专利方面，SIFT和SURF的一个很好的替代品。

是的，SIFT和SURF已经获得专利，使用它们时应该付钱。 但ORB则不是这样！！

ORB基本上是FAST关键点检测器和BRIEF描述符的融合，并有许多修改以提高性能。 首先使用FAST找到关键点，然后应用Harris角点测量来找到其中的最高N个点。 它也使用金字塔来产生多尺度特征。 但是有一个问题，FAST不计算方向。 那么如果需要旋转不变性怎么办？ 作者对于原有算法提出了以下修改。

它计算位于中心角的片段的强度加权质心。 这个角点到质心的矢量的方向就是特征点的方向。 为了改善旋转不变性，用x和y来计算矩，其应该在半径为$r$的圆形区域中，其中$r$是片段的大小。

现在来看看描述符，ORB使用BRIEF描述符。 但是我们已经看到，对于旋转，BRIEF表现不佳。 ORB所做的就是根据关键点的方向来“引导”BRIEF。 对于在位置$(x_i,y_i)$的$n$个二进制测试的任何特征集合，定义包含这些像素的坐标的$2*n$的矩阵$S$。 然后使用片段的方向$\theta$，找到它的旋转矩阵并旋转$S$以得到导向（旋转）过的版本$S_\theta$。

ORB将该角度离散为$\frac {2\pi} {30}$（12度）的增量，并构建一个预先计算好的BRIEF模式的查找表。只要关键点取向$\theta$在视图之间是一致的，正确的一组点$S_\theta$将被用来计算它的描述符。

BRIEF具有一个重要的特点，即每个位特征具有很大的方差和接近0.5的平均值。但一旦以关键点为导向，就会失去这种属性，变得更加分散。

高的方差使得特征更具有区别性，因为它对输入有不同的响应。

另一个理想的特性是使测试不相关，因为每个测试都会对测试结果产生影响。为了解决所有这些问题，ORB在所有可能的二进制测试中运行一个贪婪的搜索，以找到具有高的方差、值平均接近0.5以及测试不相关的的那些。

结果被称为**rBRIEF**。

对于描述符匹配，使用了从传统LSH改进而来的多探针LSH。这篇论文说ORB比SURF和SIFT快得多，ORB描述符比SURF更好。 ORB是低功耗设备进行全景拼接等计算的理想选择。

## OpenCV中的ORB

像往常一样，我们必须使用函数`cv2.ORB()`或使用feature2d的通用接口来创建一个ORB对象。 它有一些可选的参数。 最有用的是`nFeatures`，表示要保留的特征的最大数量（默认为500），`scoreType`表示是否使用Harris分数或FAST分数来排列特征（默认为Harris分数）。另一个参数`WTA_K`决定产生定向的BRIEF描述符的每个元素的点数。 默认情况下，这个值是2，即一次选择两个点。 在这种情况下，匹配使用`NORM_HAMMING`距离。

如果`WTA_K`是3或者4，那么需要3或者4个点来生成BRIEF描述符，那么匹配就使用`NORM_HAMMING2`。

下面是一个显示ORB使用的简单代码。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt
img = cv2.imread('simple.jpg',0)
# 初始化ORB检测器
orb = cv2.ORB_create()
# 用ORB查找关键点
kp = orb.detect(img,None)
# 用ORB计算描述子
kp, des = orb.compute(img, kp)
# 只绘制关键点位置，不绘制大小和方向
img2 = cv2.drawKeypoints(img, kp, None, color=(0,255,0), flags=0)
plt.imshow(img2), plt.show()
```

可以看见下面的结果：

![image](images/orb_kp.jpg)

我们将在其他章节中讲解使用ORB特征来做匹配。

[^1]: http://www.vision.cs.chubu.ac.jp/CV-R/pdf/Rublee_iccv2011.pdf

