# 图像二值化处理{#tutorial_py_thresholding_cn}

## 目标

- 在本教程中，您将学习简单二值化，自适应二值化，Otsu二值化等。
- 你会学到这些函数：`cv2.threshold`，`cv2.adaptiveThreshold`等。

## 简单二值化

简单二值化是很直截了当的一种方法。如果像素值大于阈值，则分配一个值（可以是白色），否则分配另一个值（可以是黑色）。使用的函数是`cv2.threshold`。第一个参数是源图像，**这应该是灰度图像**。第二个参数是用于分类像素值的阈值。第三个参数是`maxVal`，它表示像素值大于（有时是小于）阈值时要给出的值。 OpenCV提供了不同类型的阈值，由函数的第四个参数决定。有以下几种不同的类型：

- `cv2.THRESH_BINARY`
- `cv2.THRESH_BINARY_INV`
- `cv2.THRESH_TRUNC`
- `cv2.THRESH_TOZERO`
- `cv2.THRESH_TOZERO_INV`

文档清楚地解释了每种类型的意义。请查看文档。

函数有两个输出。第一个是后面会解释的`retval`。第二个输出是得到的二值化图像。

代码：

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('gradient.png',0)
ret,thresh1 = cv2.threshold(img,127,255,cv2.THRESH_BINARY)
ret,thresh2 = cv2.threshold(img,127,255,cv2.THRESH_BINARY_INV)
ret,thresh3 = cv2.threshold(img,127,255,cv2.THRESH_TRUNC)
ret,thresh4 = cv2.threshold(img,127,255,cv2.THRESH_TOZERO)
ret,thresh5 = cv2.threshold(img,127,255,cv2.THRESH_TOZERO_INV)

titles = ['Original Image','BINARY','BINARY_INV','TRUNC','TOZERO','TOZERO_INV']
images = [img, thresh1, thresh2, thresh3, thresh4, thresh5]

for i in xrange(6):
    plt.subplot(2,3,i+1),plt.imshow(images[i],'gray')
    plt.title(titles[i])
    plt.xticks([]),plt.yticks([])

plt.show()
```

要绘制多个图像，我们使用了`plt.subplot()`函数。请检查Matplotlib文档的来获取更多细节。

结果如下：

![image](images/threshold.jpg)

## 自适应阈值

在前一节中，我们对于整张图像应用了同一个阈值。但是在不同的图像区域，在光照条件不同的条件下，这样做可能并不好。在这样的情况下，我们应该使用自适应阈值。该算法会计算图像的小区域的阈值。因此，对于同一图像的不同区域，我们可以得到不同的阈值，并且对于具有变化的照明的图像给出更好的结果。

它有三个“特殊”的输入参数和一个输出参数。

- 自适应方法 - 决定如何计算阈值。

  - `cv2.ADAPTIVE_THRESH_MEAN_C`：阈值是邻域的平均值。

  - `cv2.ADAPTIVE_THRESH_GAUSSIAN_C`：阈值是高斯窗口的邻域值的加权和。

- 区块大小 - 决定邻域的大小。

- C - 一个常数，从平均值或加权平均值中减去。

下面的一段代码比较了全局阈值和自适应阈值对于不同亮度的图像的不同效果：

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('sudoku.png',0)
img = cv2.medianBlur(img,5)

ret,th1 = cv2.threshold(img,127,255,cv2.THRESH_BINARY)
th2 = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,11,2)
th3 = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C,cv2.THRESH_BINARY,11,2)

titles = ['Original Image', 'Global Thresholding (v = 127)',
            'Adaptive Mean Thresholding', 'Adaptive Gaussian Thresholding']
images = [img, th1, th2, th3]

for i in xrange(4):
    plt.subplot(2,2,i+1),plt.imshow(images[i],'gray')
    plt.title(titles[i])
    plt.xticks([]),plt.yticks([])
plt.show()
```

结果：

![image](images/ada_threshold.jpg)

## Otsu二值化

在第一部分中，我告诉过你`cv2.threshold`有第二个参数`retVal`。当我们使用Otsu二值化时要使用到它。那它到底是什么呢？

在使用全局阈值的二值化过程中，我们使用了一个任意的值作为阈值，对吧？那么，我们怎么能知道我们选择的阈值是好还是不好呢？答案是，试错。但如果有一个双峰图像（简单来说，双峰图像是一个直方图有两个峰值的图像），对于这个图像，我们可以近似地将这些峰值的中间值作为阈值，对吗？

这就是Otsu二值化所做的。简单来说，它会自动计算一个双峰图像的图像直方图阈值。 （对于不是双峰图像的图像，二值化将不准确。）

为此，我们使用`cv2.threshold()`函数，但传入一个额外的flag，`cv2.THRESH_OTSU`。对于阈值，只需传递零。然后，算法将找到最佳阈值，并返回您作为第二个输出`retVal`。如果不使用Otsu二值化，则`retVal`与您使用的阈值相同。

看看下面的例子。输入图像是一个混乱的图像。在第一种情况下，我使用了阈值为127的简单二值化。第二种情况，我直接应用了Otsu二值化。在第三种情况下，我用5x5高斯核来对图像进行滤波来去除噪声，然后应用Otsu阈值。看看噪声过滤是如何改善结果的。

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('noisy2.png',0)

# 全局阈值二值化
ret1,th1 = cv2.threshold(img,127,255,cv2.THRESH_BINARY)

# Otsu二值化
ret2,th2 = cv2.threshold(img,0,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU)

# 高斯滤波后再进行Otsu二值化
blur = cv2.GaussianBlur(img,(5,5),0)
ret3,th3 = cv2.threshold(blur,0,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU)

# 画出所有图片和它们的直方图
images = [img, 0, th1,
          img, 0, th2,
          blur, 0, th3]
titles = ['Original Noisy Image','Histogram','Global Thresholding (v=127)',
          'Original Noisy Image','Histogram',"Otsu's Thresholding",
          'Gaussian filtered Image','Histogram',"Otsu's Thresholding"]

for i in xrange(3):
    plt.subplot(3,3,i*3+1),plt.imshow(images[i*3],'gray')
    plt.title(titles[i*3]), plt.xticks([]), plt.yticks([])
    plt.subplot(3,3,i*3+2),plt.hist(images[i*3].ravel(),256)
    plt.title(titles[i*3+1]), plt.xticks([]), plt.yticks([])
    plt.subplot(3,3,i*3+3),plt.imshow(images[i*3+2],'gray')
    plt.title(titles[i*3+2]), plt.xticks([]), plt.yticks([])
plt.show()
```

结果：

![image](images/otsu.jpg)

### Otsu二值化是怎么工作的？

本节演示Otsu二值化的Python实现，以显示其实际工作原理。如果你对此不感兴趣，你可以跳过这些。

由于我们正在处理双峰图像，所以Otsu的算法试图找到一个阈值（t），这个阈值（t）使由以下关系给出的**加权的类内方差**最小化：
$$
\sigma_w^2(t) = q_1(t)\sigma_1^2(t)+q_2(t)\sigma_2^2(t) \\
where\\
q_1(t) = \sum_{i=1}^{t} P(i) \quad \& \quad q_1(t) = \sum_{i=t+1}^{I} P(i)\\ 
\mu_1(t) = \sum_{i=1}^{t} \frac{iP(i)}{q_1(t)} \quad \& \quad \mu_2(t) = \sum_{i=t+1}^{I} \frac{iP(i)}{q_2(t)}\\
\sigma_1^2(t) = \sum_{i=1}^{t} [i-\mu_1(t)]^2 \frac{P(i)}{q_1(t)} \quad \& \quad \sigma_2^2(t) = \sum_{i=t+1}^{I} [i-\mu_1(t)]^2 \frac{P(i)}{q_2(t)}
$$


它实际上找到了一个位于两个峰之间的t值，这样两个类的方差都是最小的。它可以简单地在Python中实现如下：

```python
img = cv2.imread('noisy2.png',0)
blur = cv2.GaussianBlur(img,(5,5),0)

# 找到归一化的直方图及其累积分布函数
hist = cv2.calcHist([blur],[0],None,[256],[0,256])
hist_norm = hist.ravel()/hist.max()
Q = hist_norm.cumsum()

bins = np.arange(256)

fn_min = np.inf
thresh = -1
for i in xrange(1,256):
    p1,p2 = np.hsplit(hist_norm,[i]) # 概率
    q1,q2 = Q[i],Q[255]-Q[i] # 类的cumsum
    b1,b2 = np.hsplit(bins,[i]) # 权重
    
    # 寻找均值和方差
    m1,m2 = np.sum(p1*b1)/q1, np.sum(p2*b2)/q2
    v1,v2 = np.sum(((b1-m1)**2)*p1)/q1,np.sum(((b2-m2)**2)*p2)/q2
    
    # 计算最小化函数
    fn = v1*q1 + v2*q2
    if fn < fn_min:
        fn_min = fn
        thresh = i

# 使用OpenCV函数查找Otsu阈值
ret, otsu = cv2.threshold(blur,0,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU)
print( "{} {}".format(thresh,ret) )
```



*（其中一些函数在这里对你来说可能是陌生的，但是我们将在接下来的章节中介绍它们）*

## 更多资源

[Digital Image Processing, Rafael C. Gonzalez](https://www.amazon.com/Digital-Image-Processing-Rafael-Gonzalez/dp/013168728X)

## 练习

- Otsu二值化有一些可用的优化。您可以谷歌/维基/百度并实现它。