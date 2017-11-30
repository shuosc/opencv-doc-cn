# 角点检测的FAST算法{#tutorial_py_fast_cn}

## 目标

在这一章中：

- 我们将理解FAST算法的基础
- 我们将使用OpenCV中的FAST算法来找出角点

## 理论基础

我们已经看过了几个特征检测器，而且其中许多效果相当好，但是从实时应用程序的角度看，他们还不够快，一个最好的例子就是SLAM[^3]（即时定位与地图构建），在这种情况下，机器人只有有限的计算资源。

作为这种情况的一种解决方案，FAST（Features from accelerated segment test）算法在 Edward Rosten 和 Tom Drummond 2006年的论文 《Machine learning for high-speed corner detection[^1]》中被提出（这一论文在2010年被修订）。下面是这个算法的一个简要概述，请参阅原论文来获得更多细节。

（所有的图片都是从原论文中提取的）。

### 使用FAST算法进行特征检测

1. 在图像中选择一个要被识别是否为兴趣点的像素$p$。 假设它的亮度是$I_p$。

2. 选取一个合适的阈值$t$。

3. 考虑这个像素周围的16个像素的圆圈。 （见下图）

   ![image](images/fast_speedtest.jpg)

4. 如果在这个圆圈（或者说这16个像素）中存在一组（设为$n$个）连续像素亮度都比$I_p+t$亮或者都比$I_p-t$暗，那么像素$p$就是一个角点。

   这个圆圈在上图中用白色虚线圆圈表示。此处选取$n=12$。

5. 一个**高速测试**被用来排出大量非角点。这个测试只检查1、9、5和13四个像素。（先检查像素1和9是不是比中间像素亮或暗，然后检查5和13）。如果$p$是一个角点，那么这四个像素中至少有三个都比$I_p+t$亮或者都比$I_p-t$暗。如果不符合这个特点，那么$p$就不可能是一个角点。对于通过了这个测试的像素我们才需要检测检测这个圆圈上所有的像素来最终确定它是不是一个角点。这个检测方式本身性能很好，但有几个缺陷：

   - 对于选取$n<12$的情况，这种算法不适用。
   - 像素的选取不是最佳的，因为它的效率取决于查询的顺序和边缘的外观。
   - 高速测试的结果没有在后面的检测中被使用到。
   - 会检测出多个相邻的特征点。

   前三个缺陷是用机器学习方法解决的。 最后一个是使用非最大抑制来解决的。

   ### 用机器学习训练一个角点检测器

   1. 选择一组用于训练的图像（最好来自程序要应用到的领域）。

   2. 对其中每个图像运行FAST算法来找到特征点。

   3. 对于每个特征点，将它周围的16个像素作为一个向量保存起来。对每个图像执行这个步骤来获取特征向量$P$。

   4. 这16个像素中的每一个一定处于下面三种状态中：

      ![image](images/fast_eqns.jpg)

   5. 根据像素的状态，特征向量$P$被分成三个子集：$P_d$、$P_s$和$P_b$。

   6. 定义一个新的boolean变量$K_p$，若$p$是一个角点，则$K_p$为true，否则为false。

   7. 使用ID3算法[^2]（决策树分类器）使用变量$K_p$来查询每个子集以获得关于真实分类的信息。 它选择由K_p的熵测量的，产生关于候选像素是否是角的最多信息的$x$。

   8. 这个算法递归地应用在所有子集上，直至其熵为0。

   9. 这样创建的决策树可以用于其他图像的快速检测。

   ### 非最大抑制

   另一个问题是检测出多个相邻的兴趣点。 这个问题通过使用非最大抑制来解决。

   1. 计算所有检测到的特征点的得分函数$V$。 $V$是$p$和16个周围像素值之间绝对差值的总和。
   2. 考虑两个相邻的关键点，计算它们的$V$值。
   3. 丢弃$V$值较低的关键点。

   ### 总结

   这种算法比其他已经存在的角点检测算法快数倍。

   但这种算法对高水平的噪声敏感。它依赖于一个阈值。

## OpenCV中的FAST特征检测
FAST特征检测的调用方式就和OpenCV中的其他特征检测器一样。如果需要，你可以指定阈值，指定是否应用非最大抑制，要使用非最大抑制的范围等。

对于要使用非最大抑制的范围，有三个预先定义好的标志变量：

`cv2.FAST_FEATURE_DETECTOR_TYPE58`、`cv2.FAST_FEATURE_DETECTOR_TYPE712`和`cv2.FAST_FEATURE_DETECTOR_TYPE916`。

下面是检测和画出FAST检测得到的特征点的样例代码：

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt
img = cv2.imread('simple.jpg',0)
# 用默认值初始化FAST检测器对象
fast = cv2.FastFeatureDetector_create()
# 查找并画出关键点
kp = fast.detect(img,None)
img2 = cv2.drawKeypoints(img, kp, None, color=(255,0,0))
# 输出所有默认参数
print( "Threshold: {}".format(fast.getThreshold()) )
print( "nonmaxSuppression:{}".format(fast.getNonmaxSuppression()) )
print( "neighborhood: {}".format(fast.getType()) )
print( "Total Keypoints with nonmaxSuppression: {}".format(len(kp)) )
cv2.imwrite('fast_true.png',img2)
# 禁用非最大抑制
fast.setNonmaxSuppression(0)
kp = fast.detect(img,None)
print( "Total Keypoints without nonmaxSuppression: {}".format(len(kp)) )
img3 = cv2.drawKeypoints(img, kp, None, color=(255,0,0))
cv2.imwrite('fast_false.png',img3)

```

下面是这个程序的运行结果。第一幅图是开启了非最大抑制的FAST算法的结果，第二幅图是关闭了非最大抑制的FAST算法的结果：

![image](images/fast_kp.jpg)



[^1]: http://www.edwardrosten.com/work/rosten_2006_machine.pdf 
[^2]: https://zh.wikipedia.org/wiki/ID3算法
[^3]: https://zh.wikipedia.org/wiki/即时定位与地图构建

