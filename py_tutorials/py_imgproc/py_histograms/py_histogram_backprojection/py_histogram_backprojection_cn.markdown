# 直方图反投影{#tutorial_py_histogram_backprojection_cn}

## 目标

在本章中，我们将学习直方图反投影。

## 理论

它由Michael J. Swain，Dana H. Ballard在他们的论文《Indexing via color histograms》中提出。

**用简单的话来说它是什么？**它用于图像分割或查找图像中感兴趣的对象。简而言之，它会创建与我们的输入图像相同大小（但为单个通道）的图像，其中每个像素对应于该像素属于我们对象的概率。用更简单的话说，在输出的图像中，与其余的部分相比，我们感兴趣的对象更白。这是一个直观的解释。 （我不能使它更简单了）。直方图反投影常常与camshift算法等一起使用。

**我们该怎么做呢 ？**我们创建一个包含我们感兴趣的对象（在我们的例子中，这个对象是地面，而不是运动员或其他东西）的图像直方图。对象应尽可能填充图像以获得更好的效果。颜色直方图比灰度直方图更受欢迎，因为对象的颜色是定义对象的一种比其灰度强度更好的方法。然后我们在测试图像上“反投影”这个直方图，在那里我们需要找到对象，换句话说，我们计算每个像素属于地面的概率并显示出来。在适当的阈值下产生的输出将会为我们挑出地面。

## 用Numpy实现的算法

- 首先，我们需要计算我们需要找到的对象（称它是'M'）和我们要搜索的图像（称它为'I'）的颜色直方图。

  ```python
  import cv2
  import numpy as np
  from matplotlib import pyplot as plt

  # roi是我们要寻找的对象或要寻找对象的区域
  roi = cv2.imread('rose_red.png')
  hsv = cv2.cvtColor(roi,cv2.COLOR_BGR2HSV)

  # target是我们要在其中寻找对象的图片
  target = cv2.imread('rose.png')
  hsvt = cv2.cvtColor(target,cv2.COLOR_BGR2HSV)

  # 使用calcHist计算出直方图。也可以使用np.histogram2d
  M = cv2.calcHist([hsv],[0, 1], None, [180, 256], [0, 180, 0, 256] )
  I = cv2.calcHist([hsvt],[0, 1], None, [180, 256], [0, 180, 0, 256] )
  ```

- 找到比率$R = \frac {M} {I}$。然后，反向投影R，即使用R作为调色板，并以每个像素作为其相应的目标概率来创建新的图像。即$B(x,y)=R[h(x,y),s(x,y)]$，其中h是色相，s是(x,y)处像素的饱和度。之后，应用条件$B(x,y)= min [B(x,y),1]$。

  ```python
  h,s,v = cv2.split(hsvt)
  B = R[h.ravel(),s.ravel()]
  B = np.minimum(B,1)
  B = B.reshape(hsvt.shape[:2])
  ```

- 现在应用圆形卷积，$B = D \ast B$，其中D是卷积核。

  ```python
  disc = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5))
  cv2.filter2D(B,-1,disc,B)
  B = np.uint8(B)
  cv2.normalize(B,B,0,255,cv2.NORM_MINMAX)
  ```

- 现在最大亮度的位置给出了我们物体的位置。如果我们想要的图像中的一个区域，以合适的值进行二值化将会给出了很好的结果。

  ```python
  ret,thresh = cv2.threshold(B,50,255,0)
  ```

  就是这样。

## OpenCV中的反投影

OpenCV提供了一个内置函数`cv2.calcBackProject()`。它的参数几乎和`cv2.calcHist()`函数相同。其中一个参数是直方图，它是要寻找对象的直方图，我们必须自己找到它。另外，在传递给反投影函数之前，对象直方图应该被归一化。它返回概率图像。然后，我们用圆形内核卷积图像并二值化。下面是我的代码和输出：

```python
import cv2
import numpy as np

roi = cv2.imread('rose_red.png')
hsv = cv2.cvtColor(roi,cv2.COLOR_BGR2HSV)

target = cv2.imread('rose.png')
hsvt = cv2.cvtColor(target,cv2.COLOR_BGR2HSV)

# 计算对象的直方图
roihist = cv2.calcHist([hsv],[0, 1], None, [180, 256], [0, 180, 0, 256] )

# 直方图均衡化，并应用backprojection
cv2.normalize(roihist,roihist,0,255,cv2.NORM_MINMAX)
dst = cv2.calcBackProject([hsvt],[0,1],roihist,[0,180,0,256],1)

# 使用圆形内核卷积
disc = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5))
cv2.filter2D(dst,-1,disc,dst)

# 二值化，按位与
ret,thresh = cv2.threshold(dst,50,255,0)
thresh = cv2.merge((thresh,thresh,thresh))
res = cv2.bitwise_and(target,thresh)

res = np.vstack((target,thresh,res))
cv2.imwrite('res.jpg',res)
```

下面是我做的一个例子。我用蓝色矩形内的区域作为样本对象，提取了完整的地面。

![image](images/backproject_opencv.jpg)

## 更多资源

- ["Indexing via color histograms", Swain, Michael J. , Third international conference on computer vision,1990](http://scholar.google.co.jp/scholar_url?url=https://pdfs.semanticscholar.org/37d7/9bba495703fb250f1f834328d44c9292aaff.pdf&hl=zh-CN&sa=X&scisig=AAGBfm03sMABUmWk_NnWhcmSE1zcfnQXjQ&nossl=1&oi=scholarr&ved=0ahUKEwienNzxsPzXAhXLS7wKHZqXBQEQgAMIKSgAMAA)