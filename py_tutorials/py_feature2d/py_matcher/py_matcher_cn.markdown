# 特征匹配{#tutorial_py_matcher_cn}

## 目标

在这一章中，

- 我们将看到如何将一个图片上的特征和其他图片上的特征匹配起来。
- 我们将使用OpenCV中的蛮力匹配器和FLANN匹配器。

## 蛮力匹配器基础

蛮力匹配器很简单。 它采用第一组中的一个特征的描述符并且使用一些距离计算与第二组中的所有其他特征匹配。 返回最接近的一个。
对于BF匹配器，首先我们必须使用`cv2.BFMatcher()`来创建`BFMatcher`对象。 它需要两个可选的参数。 首先是`normType`。 它指定要使用的距离测量方法。 默认情况下，它是`cv2.NORM_L2`。 对于SIFT，SURF等（`cv2.NORM_L1`也在这些之中）。 对于像ORB，BRIEF，BRISK等基于二进制字符串的描述符，应该使用`cv2.NORM_HAMMING`，它使用汉明距离作为度量。 如果ORB使用`WTA_K == 3`或4，则应使用`cv2.NORM_HAMMING2`。

第二个参数是布尔变量，`crossCheck`默认为false。 如果是，Matcher只返回值为$(i,j)$的那些匹配，使得集合A中的第i个描述符在集合B中具有第j个描述符作为最佳匹配，反之亦然。 也就是说，两组中的两个特征应该相互匹配。 它提供了一致的结果，是D.Lowe在SIFT论文中提出的比率测试的一个很好的选择。

一旦一个`BFMatcher`对象被创建，两个重要的方法是`BFMatcher.match()`和`BFMatcher.knnMatch()`。 第一个返回最佳匹配。 第二个返回k个最佳匹配，其中k由用户指定。当我们需要做额外的工作时，这可能是有用的。

就像我们使用`cv2.drawKeypoints()`来绘制关键点那样，`cv2.drawMatches()`帮助我们绘制匹配。 它将两个图像水平堆叠，并从第一个图像绘制到第二个图像，显示最佳匹配。 也有`cv2.drawMatchesKnn()`函数来绘制所有k个最好的匹配。 如果$k=2$，则会为每个关键点绘制两条匹配线。 所以如果我们要选择性地绘制它，我们必须传入一个mask。

让我们来看看SURF和ORB（使用不同的距离测量）的示例。

### 用ORB描述符进行蛮力匹配

在这里，我们将看到一个关于如何匹配两个图像之间的特征的简单例子。 在这种情况下，我有一个queryImage和trainImage。 我们将尝试使用特征匹配来在queryImage中查找trainImage。 （图片是/samples/c/box.png和/samples/c/box_in_scene.png）

我们使用ORB描述符来匹配特征。 

让我们开始加载图像，找到描述符等。

```python
import numpy as np
import cv2
import matplotlib.pyplot as plt
img1 = cv2.imread('box.png',0)          # queryImage
img2 = cv2.imread('box_in_scene.png',0) # trainImage
# 初始化ORB检测器
orb = cv2.ORB_create()
# 用ORB寻找关键点和描述符
kp1, des1 = orb.detectAndCompute(img1,None)
kp2, des2 = orb.detectAndCompute(img2,None)
```

接下来我们创建一个距离测量方法为`cv2.NORM_HAMMING`的BFMatcher对象（因为我们使用的是ORB），为了获得更好的结果，我们将打开`crossCheck`。 然后我们使用`Matcher.match()`方法获得两幅图像中的最佳匹配。 我们按照距离升序对它们进行排序，以便最佳匹配（低距离）出现在前面。 然后我们只画出前10个匹配（只是为了可见性考虑。你可以随意增加这个值）。

```python
# 创建BFMatcher对象
bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)
# 匹配描述符
matches = bf.match(des1,des2)
# 按照距离排序
matches = sorted(matches, key = lambda x:x.distance)
# 画出前10个匹配
img3 = cv2.drawMatches(img1,kp1,img2,kp2,matches[:10], flags=2)
plt.imshow(img3)
plt.show()
```

下面是我的到的结果：

![image](images/matcher_result1.jpg)

## Matcher对象是什么？

`matches = bf.match(des1,des2)`这行的结果是DMatch对象的列表。 DMatch对象具有以下属性：

- DMatch.distance - 描述符之间的距离。 越低表示匹配地越好。
- DMatch.trainIdx - 训练集中描述符的索引。
- DMatch.queryIdx - 查询集中描述符的索引。
- DMatch.imgIdx - 训练图片的索引。

## 用SIFT描述符进行蛮力匹配和比率测试

这一次，我们将使用`BFMatcher.knnMatch()`来获得k个最佳匹配。 在这个例子中，我们将采取k = 2，以便我们可以应用在D.Lowe的论文中提到的比率测试。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt
img1 = cv2.imread('box.png',0)          # queryImage
img2 = cv2.imread('box_in_scene.png',0) # trainImage
# 初始化SIFT检测器
sift = cv2.SIFT()
# 用SIFT搜索关键点和描述子
kp1, des1 = sift.detectAndCompute(img1,None)
kp2, des2 = sift.detectAndCompute(img2,None)
# 用默认的BFMatcher进行匹配
bf = cv2.BFMatcher()
matches = bf.knnMatch(des1,des2, k=2)
# 进行比率测试
good = []
for m,n in matches:
    if m.distance < 0.75*n.distance:
        good.append([m])
# 用cv2.drawMatchesKnn绘制一个列表的匹配对象
img3 = cv2.drawMatchesKnn(img1,kp1,img2,kp2,good,flags=2)
plt.imshow(img3)
plt.show()
```

下面是结果：

![image](images/matcher_result2.jpg)

## 基于FLANN的Matcher

FLANN，即快速近似最邻近库。 它包含一组经过优化的算法，用于大数据集中的快速最近邻搜索以及高维特征。 对于大数据集，它的工作速度比BFMatcher快。 我们将看到基于FLANN的匹配器的第二个例子。

对于基于FLANN的匹配器，我们需要传递两个字典，指定要使用的算法，相关的参数等。首先是IndexParams。 对于各种算法，要传递的信息在FLANN文档中进行了解释。 总而言之，对于像SIFT，SURF等算法，您可以传入以下这些东西：

```python
FLANN_INDEX_KDTREE = 1
index_params = dict(algorithm = FLANN_INDEX_KDTREE, trees = 5)
```

在使用ORB的时候，你可以传入下面这些值。 这些值都是文档推荐的值，但在某些情况下这些值不会提供所需的结果。 而其他值却工作正常。

```python
FLANN_INDEX_LSH = 6
index_params= dict(algorithm = FLANN_INDEX_LSH,
                   	table_number = 6, # 12
               		key_size = 12,     # 20
              	 	multi_probe_level = 1) #2
```

第二个字典是SearchParams。 它指定了索引中的树应递归遍历的次数。 更高的值会提高精度，但也需要更多的时间。 如果你想改变这个值，传入`search_params = dict（checks = 100）`。

有了这些信息，我们就准备好了。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt
img1 = cv2.imread('box.png',0)          # queryImage
img2 = cv2.imread('box_in_scene.png',0) # trainImage
# 初始化SIFT检测器
sift = cv2.SIFT()
# 用SIFT找到关键点和描述符
kp1, des1 = sift.detectAndCompute(img1,None)
kp2, des2 = sift.detectAndCompute(img2,None)
# FLANN参数
FLANN_INDEX_KDTREE = 1
index_params = dict(algorithm = FLANN_INDEX_KDTREE, trees = 5)
search_params = dict(checks=50)   # 或者传入空的字典
flann = cv2.FlannBasedMatcher(index_params,search_params)
matches = flann.knnMatch(des1,des2,k=2)
# 只需要画出好的匹配，所以创建一个mask
matchesMask = [[0,0] for i in xrange(len(matches))]
# 比率测试
for i,(m,n) in enumerate(matches):
    if m.distance < 0.7*n.distance:
        matchesMask[i]=[1,0]
        draw_params = dict(matchColor = (0,255,0),
                        singlePointColor = (255,0,0),
               			matchesMask = matchesMask,
               			flags = 0)
        img3 = cv2.drawMatchesKnn(img1,kp1,img2,kp2,matches,None,**draw_params)
plt.imshow(img3,)
plt.show()
```

可以看见下面的结果。

![image](images/matcher_flann.jpg)