# 图像去噪{#tutorial_py_non_local_means_cn}

## 目标

在这一章当中，

- 您将了解非局部均值消噪算法，以消除图像中的噪声。
- 你会看到几个不同的函数，如`cv2.fastNlMeansDenoising()`，
    `cv2.fastNlMeansDenoisingColored()`等

## 理论基础

在前面的章节中，我们看到了许多像高斯模糊，中值模糊等图像平滑技术，它们在一定程度上消除了少量的噪声。在这些技术中，我们在像素周围采取了一个小的邻域，并进行了一些像高斯加权平均值，取中位数等操作，用结果来代替中心元素。总之，一个像素处的噪声消除被限制在其邻域内。

噪声有一个属性。噪声通常被认为是零均值的随机变量。考虑有噪声的像素，$p = p_0 + n$，其中$p_0$是像素的真实值，$n$是该像素中的噪声。您可以从不同的图像中获取大量相同的像素（比如说$N$个）并计算它们的平均值。理想情况下，你应该得到$p = p_0$，因为噪声的均值为零。

您可以通过简单的设置自行验证。拿一个静态摄像头，将它放在一个特定的位置几秒钟。这会给你很多的帧，或者是同一场景的很多图像。然后写一段代码找到视频中所有帧的平均值（现在这对你来说应该太简单了）。比较最终结果和第一帧。你可以看到噪声的减少。不幸的是，这种简单的方法不适用于相机和场景的运动。同时往往也只有一幅嘈杂的图像可用。

所以想法很简单，我们需要一组相似的图像来平均噪音。考虑图像中的一个小窗口（比如5x5窗口）。相同的图像片很有可能在图像中的其他地方。有时在一个小的领域周围。如何将这些相似的图像片一起使用并找到它们的平均值？对于特定的窗口，这样做效果很好。看下面的示例图片：

![image](images/nlm_patch.jpg)

图像中的蓝色图像块看起来相似。绿色图像块看起来相似。所以我们取一个像素，取围绕它周围的小窗口，在图像中搜索相似的窗口，平均所有的窗口，并用我们得到的结果取代像素。这种方法是非局部的去噪。与我们之前看到的模糊技术相比，它需要更多的时间，但是结果非常好。更多的细节和在线演示可以在更多资源的第一个链接。

对于彩色图像，图像将会转换为CIELAB色彩空间，然后分别去除L和AB分量。

## OpenCV中的图像去噪

OpenCV提供了这种技术的四种变体。

- `cv2.fastNlMeansDenoising()` - 适用于单个灰度图像
- `cv2.fastNlMeansDenoisingColored() `- 适用于彩色图像。
- `cv2.fastNlMeansDenoisingMulti()` - 适用于短时间捕获的图像序列（灰度图像）
- `cv2.fastNlMeansDenoisingColoredMulti()` - 与上面相同，但是是彩色图像。

它们共同的参数是：

- `h`：参数决定滤波强度。较高的h值可以更好地去除噪点，但也会去除图像的细节。 （一般来说10是一个好的值）


- `hForColorComponents`：与h相同，但仅适用于彩色图像。 （通常与h相同）
- `templateWindowSize`：应该是奇数。 （推荐7）
- `searchWindowSize`：应该是奇数。 （推荐21）

有关这些参数的更多详细信息，请访问更多资源的第一个链接。

我们将在这里展示2和3。其他留给你。

### 1. `cv2.fastNlMeansDenoisingColored()`

如上所述，它用于去除彩色图像中的噪声。 （噪音预计是高斯噪声）。

看下面的例子：

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt

img = cv2.imread('die.png')
dst = cv2.fastNlMeansDenoisingColored(img,None,10,10,7,21)
plt.subplot(121),plt.imshow(img)
plt.subplot(122),plt.imshow(dst)
plt.show()
```

以下是结果缩放过的版本。 我的输入图像具有$\sigma = 25$的高斯噪声。查看结果：

![image](images/nlm_result1.jpg)

### 2. `cv2.fastNlMeansDenoisingMulti()`

现在我们将对视频使用相同的方法。 第一个参数是有噪声的帧的列表。 第二个参数`imgToDenoiseIndex`指定我们需要去噪的帧，因为我们在输入列表中传递了帧的索引。 第三个是`temporalWindowSize`，它指定了用于去噪的附近帧的数量。 这应该是个奇数。 在那种情况下，总共使用`temporalWindowSize`帧，其中中央帧是要被去噪的帧。 例如，您传递了5个框架的列表作为输入。 让`imgToDenoiseIndex = 2`和`temporalWindowSize = 3`。那么将会使用frame-1，frame-2和frame-3来消除frame-2中的噪声。 我们来看一个例子。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt

cap = cv2.VideoCapture('vtest.avi')

# 创建一个有5个帧的列表
img = [cap.read()[1] for i in xrange(5)]

# 全部转换到灰度图
gray = [cv2.cvtColor(i, cv2.COLOR_BGR2GRAY) for i in img]

# 全部转换到float64
gray = [np.float64(i) for i in gray]

# 创建一个标准差为25的噪声
noise = np.random.randn(*gray[1].shape)*10

# 向图像中添加噪声
noisy = [i+noise for i in gray]

# 转回uint8
noisy = [np.uint8(np.clip(i,0,255)) for i in noisy]

# 使用全部5帧来为第三帧去噪
dst = cv2.fastNlMeansDenoisingMulti(noisy, 2, 5, None, 4, 7, 35)

plt.subplot(131),plt.imshow(gray[2],'gray')
plt.subplot(132),plt.imshow(noisy[2],'gray')
plt.subplot(133),plt.imshow(dst,'gray')
plt.show()
```

下图显示了我们得到的结果的缩放版本：

![image](images/nlm_multi.jpg)

计算需要相当长的时间。 在结果图像中，第一个图像是原始图像，第二个图像是添加了噪声的图像，第三个图像是去噪后的图像。

## 更多资源

- http://www.ipol.im/pub/art/2011/bcm_nlm/（详细信息，在线演示等，强烈建议访问，我们的测试图像是从这个链接生成的）
- [coursera的在线课程](https://www.coursera.org/course/images)（第一张图片是从这里获得的）