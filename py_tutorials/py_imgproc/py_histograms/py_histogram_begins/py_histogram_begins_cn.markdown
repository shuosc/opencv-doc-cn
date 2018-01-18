# 直方图：查找，绘制，分析！{#tutorial_py_histogram_begins_cn}

## 目标

学习

- 使用OpenCV和Numpy函数查找直方图
- 绘制直方图，使用OpenCV和Matplotlib函数
- 你会学到这些函数：`cv2.calcHist()`，`np.histogram()`等

## 理论基础

什么是直方图？您可以将直方图视为一个图形，它将会为您提供有关图像强度分布的大体情况。这是一个在X轴上具有像素值（一般来说是从0到255，但并非总是这样）的图形，并且在Y轴上具有相应的像素数量。

直方图只是理解图像的另一种方式。通过查看图像的直方图，您可以直观了解该图像的对比度，亮度，强度分布等。目前几乎所有的图像处理工具都提供了直方图上功能。以下是来自[Cambridge in Color网站](http://www.cambridgeincolour.com/tutorials/histograms1.htm)的图片，我建议您访问该网站了解更多详情。

![image](images/histogram_sample.jpg)

你可以看到图像和直方图。 （请记住，这个直方图是为灰度图像绘制的，而不是彩色图像）。直方图的左侧区域显示图像中较暗像素的数量，右侧区域显示较亮像素的数量。从直方图中，您可以看到黑色区域比明亮区域多，中间色调（中等范围内的像素值，例如127左右）的数量非常少。

## 查找直方图

现在我们心中有直方图的概念了，我们可以来看看如何找到它了。 OpenCV和Numpy都有内置的函数。在使用这些函数之前，我们需要了解一些与直方图有关的术语。

**BINS**：上面的直方图显示了每个像素值的像素数量，即从0到255。也就是说，您需要256个值来显示上述直方图。但是想一想，如果你不需要分别找出所有像素值的像素数量，而是需要找到每个像素值的区间中的像素数量怎么办？举例来说，您需要找到位于0到15之间，然后是16到31，...，240到255之间的像素数目。

您将只需要16个值来表示直方图。这就是OpenCV教程中关于直方图的例子。

所以你所做的只是将整个直方图拆分为16个子部分，每个子部分的值是其中所有像素数的总和。这个子部分被称为“面元（BIN）”。在第一种情况下，面元的数量是256（每种亮度的像素一个），而在第二种情况下，只有16个。在OpenCV文档中，面元数量由术语histSize表示。

**DIMS**：这是我们收集数据的参数数量。在这种情况下，只收集关于一个东西的数据，即强度值的数据。所以这里是1。

**RANGE**：这是您要测量的强度值的范围。通常，它是[0,256]，即所有强度值。

1. OpenCV中的直方图计算

   所以现在我们使用`cv2.calcHist()`函数来查找直方图。让我们熟悉这个函数及其参数：

   ```python
   cv2.calcHist(images, channels, mask, histSize, ranges[, hist[, accumulate]])
   ```
   - `images`：它是类型为uint8或float32的源图像。应该将其放在方括号传入，即`[img]`。

    - `channels`：它也应该放在方括号内。这是我们计算直方图的通道索引。例如，如果输入是灰度图像，则其值为[0]。对于彩色图像，可以通过[0]，[1]或[2]分别计算蓝色，绿色或红色通道的直方图。

   - `mask`：mask图片。要查找完整图像的直方图，可以传入`None`。但是，如果你想找到特定区域的图像直方图，你必须创建一个mask图像，并将其作为传入。 （我稍后会举例说明。）

   - `histSize`：这代表我们的面元数量。需放入方括号给出。对于全部像素值，我们传入`[256]`。

   - `ranges`：这是我们的RANGE。通常是[0,256]。

   那么让我们从一个示例图像开始。只需以灰度模式加载图像，并找到完整的图像直方图。

   ```python
   img = cv2.imread('home.jpg',0)
   hist = cv2.calcHist([img],[0],None,[256],[0,256])
   ```

   hist是一个256x1数组，每个值对应于该图像中具有其对应像素值的像素的数量。

2. Numpy中的直方图计算

   Numpy也为你提供了一个函数`np.histogram()`。所以，替代`calcHist()`函数，你可以尝试使用下面这行代码：

   ```python
   hist,bins = np.histogram(img.ravel(),256,[0,256])
   ```

   hist与我们之前计算的相同。但是bins将会有257个元素，因为Numpy计算的bins为0-0.99,1-1.99,2-2.99等，所以最后的范围是255-255.99。为了表示这个范围，他们在bin结尾加上了256。但是我们不需要256。到255就足够了。

   numpy有另外一个函数，`np.bincount()`，它比`np.histogram()`要快得多（10倍左右）。所以对于一维直方图，你可以最好尝试一下它。不要忘记在`np.bincount`中设置`minlength = 256`。例如:

   ```python
    hist = np.bincount(img.ravel(),minlength=256)
   ```

   OpenCV函数比`np.histogram()`要快（大约40X）。所以应该坚持使用OpenCV函数。

   现在我们应该绘制直方图了，但是应该怎么做呢？

## 绘制直方图

有两种方法来做到这一点，

- 捷径：使用Matplotlib绘图功能
- 不那么方便的方法：使用OpenCV绘图功能

1. 使用Matplotlib

   Matplotlib带有一个直方图绘图函数：`matplotlib.pyplot.hist()`

   它直接找到直方图并绘制它。您不需要使用`calcHist()`或`np.histogram()`函数找到直方图。请参阅下面的代码：

   ```python
   import cv2
   import numpy as np
   from matplotlib import pyplot as plt
   img = cv2.imread('home.jpg',0)
   plt.hist(img.ravel(),256,[0,256]); plt.show()
   ```

   你会得到下面的图片：

   ![image](images/histogram_matplotlib.jpg)

   或者你可以使用matplotlib的普通plot，这对于BGR图像来说比较好用。为此，您需要首先查找直方图数据。尝试下面的代码：

   ```python
   import cv2
   import numpy as np
   from matplotlib import pyplot as plt

   img = cv2.imread('home.jpg')
   color = ('b','g','r')
   for i,col in enumerate(color):
       histr = cv2.calcHist([img],[i],None,[256],[0,256])
       plt.plot(histr,color = col)
       plt.xlim([0,256])
   plt.show()
   ```

   结果如下：

   ![image](images/histogram_rgb_plot.jpg)

   你可以从上面的图中看出，蓝色值在图像中有一些高的区域（显然这应该是由于天空）

2. 使用OpenCV

   您可以将直方图的值与其面元值一起调整为(x,y)坐标，以便您可以使用`cv2.line()`或`cv2.polyline()`函数绘制直方图以生成与上面相同的图像。 OpenCV-Python的官方示例已经展示了这一点。检查`samples/python /hist.py`中的代码。

## 应用mask

我们使用`cv2.calcHist()`来查找完整图像的直方图。如果你想找到一个图像的某些区域的直方图呢？只需在要查找直方图的区域创建一个白色的mask图像，否则就是黑色。然后传入这个mask。

```python
img = cv2.imread('home.jpg',0)

# 创建一个mask
mask = np.zeros(img.shape[:2], np.uint8)
mask[100:300, 100:400] = 255
masked_img = cv2.bitwise_and(img,img,mask = mask)

# Calculate histogram with mask and without mask
# 计算出直方图，一个用mask，另一个不用
hist_full = cv2.calcHist([img],[0],None,[256],[0,256])
hist_mask = cv2.calcHist([img],[0],mask,[256],[0,256])

plt.subplot(221), plt.imshow(img, 'gray')
plt.subplot(222), plt.imshow(mask,'gray')
plt.subplot(223), plt.imshow(masked_img, 'gray')
plt.subplot(224), plt.plot(hist_full), plt.plot(hist_mask)
plt.xlim([0,256])

plt.show()
```

看下面的结果。在直方图中，蓝线显示完整图像的直方图，而绿线显示mask出的区域的直方图。

![image](images/histogram_masking.jpg)

## 更多资源

- [Cambridge in Color 网站](http://www.cambridgeincolour.com/tutorials/histograms1.htm)

