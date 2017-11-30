# BRIEF特征点描述算法[^1] {#tutorial_py_brief_cn}

## 目标

在这一章中：

- 我们将学习BRIEF算法的基础知识

## 理论基础

SIFT[^2]算法使用128维的向量描述符。由于它使用的是浮点数，因此它至少需要512字节。相似地，SURF[^3]算法也至少需要256字节（64维）。创建这样一个数以千计的特征向量需要大量的内存，这对于一个资源有限的应用，尤其是嵌入式系统上的应用来说是不可接受的。而且所消耗的内存空间越多，匹配花费的时间也越长。

但是实际匹配可能不需要所有这些维度。我们可以使用几个像PCA[^5]，LDA[^6]这样的方法压缩它。甚至还有一些方法像是使用LSH[^4]进行哈希的方法来将浮点数表示的这些SIFT描述符转换为二进制向量。这些二进制向量可以用Hamming距离[^7]来进行特征匹配。这进一步提升了速度，因为计算Hamming距离只是执行异或指令和进行位计数，在有SSE指令集的现代计算机上这是相当快的。但是如果要使用这种方法，我们需要先找到描述符，然后才能使用哈希算法，这代表这种方法并不能解决我们最初的内存问题。

此时BRIEF算法就可以发挥作用了。它可以不寻找描述符而直接得到二进制向量。 它接受平滑过的图像集并以一种独特的方式（在论文中有解释）选择几组$n_d$$(x,y)$坐标。 然后进行像素强度比较。 例如，假设第一个位置对是$p$和$q$。 如果$I(p)<I(q)$，那么结果是1，否则是0。对所有的$n_d$坐标进行这样的比较之后，我们就可以得到一个$n_d$维的二进制向量。

这里的$n_d$可以是128、256或512。OpenCV支持所有这些值，但默认情况下$n_d$是256（OpenCV使用字节来计算$n_d$的大小，所以这些值在OpenCV中就是16、32和64）。只要你得到了这个结果，你就能使用Hamming距离来匹配这些描述符。

重要的一点是BRIEF是一个特征描述符，它没有提供任何方法来查找特征。 因此，你需要使用其他特征检测器，如SIFT，SURF等。论文推荐使用CenSurE，这是一种快速特征检测器，而且使用它检测得到的特征点来执行BRIEF算法相对于使用SURF检测到的点来说效果会稍好一些。

简而言之，BRIEF是一种更快的进行特征描述符计算和匹配的方法。 除非有很剧烈的平面内旋转，否则它的识别率也很高。

## OpenCV中的BRIEF

下面的代码展示了如何使用CenSurE检测器获取的特征点来计算BRIEF描述符。

 (在OpenCV中CenSurE检测器被称作STAR检测器)。

注意，你需要[OpenCV contrib](https://github.com/opencv/opencv_contrib)来使用这些代码。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt
img = cv2.imread('simple.jpg',0)
# Initiate FAST detector
star = cv2.xfeatures2d.StarDetector_create()
# Initiate BRIEF extractor
brief = cv2.xfeatures2d.BriefDescriptorExtractor_create()
# find the keypoints with STAR
kp = star.detect(img,None)
# compute the descriptors with BRIEF
kp, des = brief.compute(img, kp)
print( brief.descriptorSize() )
print( des.shape )
```

`brief.getDescriptorSize()`获取$n_d$的大小（以字节为单位）。默认值是32。接下来要做的事就是匹配，我们将会在另外一章中介绍它。

[^1]: http://icwww.epfl.ch/~lepetit/papers/calonder_eccv10.pdf 
[^2]: https://zh.wikipedia.org/wiki/尺度不變特徵轉換
[^3]: https://zh.wikipedia.org/wiki/加速稳健特征
[^4]: https://en.wikipedia.org/wiki/Locality-sensitive_hashing
[^5]: https://zh.wikipedia.org/wiki/主成分分析
[^6]: https://zh.wikipedia.org/wiki/線性判別分析
[^7]: https://zh.wikipedia.org/wiki/汉明距离
