# 直方图均衡化{#tutorial_py_histogram_equalization_cn}

## 目标

在这一章中，

- 我们将学习直方图均衡的概念，并用它来改善我们的图片对比度。

## 理论基础

考虑像素值仅限于某个特定值范围的图像。例如，较亮的图像将所有像素限制在较高的值。但是一张好的图像将会具有来自图像所有区域的像素。所以你需要将这个直方图拉伸到两端（如下图所示，图片来自维基百科），用简单的话来说，这就是直方图均衡化所能做到的。这通常会改善图像的对比度。

![image](images/histogram_equalization.png)

我建议你阅读关于直方图均衡化的[维基百科页面](https://zh.wikipedia.org/wiki/直方图均衡化)，了解更多细节。它解释的很好而且有相当好的例子，所以在阅读完后你几乎可以理解所有有关于此的东西。在这里我们将看到它的Numpy实现。之后，我们将看到OpenCV函数。

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('wiki.jpg',0)
hist,bins = np.histogram(img.flatten(),256,[0,256])
cdf = hist.cumsum()
cdf_normalized = cdf * float(hist.max()) / cdf.max()
plt.plot(cdf_normalized, color = 'b')
plt.hist(img.flatten(),256,[0,256], color = 'r')
plt.xlim([0,256])
plt.legend(('cdf','histogram'), loc = 'upper left')
plt.show()
```

你可以看到直方图集中在在更明亮的区域。我们需要更为平均的直方图。为此，我们需要一个转换函数，将输入像素在较亮的区域映射到全区域的输出像素。这就是直方图均衡化。

现在我们找到最小的直方图值（不包括0），并应用wiki页面中给出的直方图均衡方程。但是我在这里使用了来自Numpy的mask数组的概念。对于mask数组，所有操作都在没有被mask掉的元素上执行。你可以从Numpy文档中的masked数组读到更多相关的知识。

```python
cdf_m = np.ma.masked_equal(cdf,0)
cdf_m = (cdf_m - cdf_m.min())*255/(cdf_m.max()-cdf_m.min())
cdf = np.ma.filled(cdf_m,0).astype('uint8')
```

现在我们有了一个查找表，它给出了关于每个输入像素值的输出像素值的信息。所以我们只是应用转换。

```python
img2 = cdf[img]
```



现在我们像以前一样计算它的直方图和cdf（你来做），结果如下所示：

![image](images/histeq_numpy2.jpg)

另一个重要的特征是，即使图像是一个较暗的图像（而不是一个像我们使用的这张一样的更亮的图像），均衡后，我们将得到几乎相同的图像，就像我们现在得到这张一样。因此，这被用作“参考工具”来使所有图像具有相同的照明条件。这在许多情况下是有用的。例如，在人脸识别中，在用人脸识别数据训练模型之前，需要对人脸图像进行直方图均衡化处理，使其全部具有相同的照明条件。

## OpenCV中的直方图均衡化

OpenCV有一个函数来做到这一点，`cv2.equalizeHist()`。它的输入只是灰度图像，输出是直方图均衡过的图像。

下面是一个简单的代码片段，显示了我们使用的相同图片时的处理方法：

```python
img = cv2.imread('wiki.jpg',0)
equ = cv2.equalizeHist(img)
res = np.hstack((img,equ)) # 将图像拼起来
cv2.imwrite('res.png',res)
```

![image](images/equalization_opencv.jpg)

所以现在你可以在不同的光照条件下拍摄不同的图像，均衡它并检查结果。

当图像的直方图被限制在特定的区域时，直方图均衡是很好的。在直方图覆盖较大的区域，强度变化较大的地方，即同时存在明亮和暗淡的像素的情况下，这种方法将不会奏效。请查看更多资源中的SOF链接。

## CLAHE（限制对比度的自适应直方图均衡）

我们刚刚看到了第一个直方图均衡算法，它只考虑了图像的全局对比度。在很多情况下，这不是一个好主意。例如，下图显示了全局直方图均衡之后的输入图像及其结果。

![image](images/clahe_1.jpg)

在直方图均衡之后，背景对比度已经得到改善。但是比较两幅图像中的雕像的面貌。由于亮度过高，我们丢失了大部分的信息。这是因为它的直方图并不像我们在前面的例子中看到的那样局限于特定的区域（试试看绘制出输入图像的直方图，你会了解更多）。

所以为了解决这个问题，我们要使用**自适应直方图均衡**。在这里，图像被分成称为“tiles”的小块（在OpenCV中tileSize默认为8x8）。然后每个块都像平常一样进行直方图均衡。所以直方图均衡会局限于一个小区域（除非有噪音）。如果有噪音，它会被放大。为了避免这种情况，需要应用**对比度限制**。如果任何直方图的面元超过了指定的对比度限制（在OpenCV中默认为40），那么在应用直方图均衡之前，这些像素将被裁切并均匀分配到其他面元。均衡之后，为了去除tiles边界中的伪影(artifacts)，我们使用了双线性插值。

下面的代码片段显示了如何在OpenCV中应用CLAHE：

```python
import numpy as np
import cv2

img = cv2.imread('tsukuba_l.png',0)

# 创建一个 CLAHE 对象 (参数是可选的)
clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
cl1 = clahe.apply(img)

cv2.imwrite('clahe_2.jpg',cl1)
```



看看下面的结果，并与上面的结果进行比较，特别是雕像区域：

![image](images/clahe_2.jpg)

## 更多资源

- 直方图均衡化的[维基百科页面](https://zh.wikipedia.org/wiki/直方图均衡化)
- [Numpy中的Masked Arrays](http://docs.scipy.org/doc/numpy/reference/maskedarray.html)

还可以看看这些Stackoverflow上的有关对比度调整的问题：

- [How can I adjust contrast in OpenCV in C?](http://stackoverflow.com/questions/10549245/how-can-i-adjust-contrast-in-opencv-in-c)
- [How do I equalize contrast & brightness of images using opencv?](http://stackoverflow.com/questions/10561222/how-do-i-equalize-contrast-brightness-of-images-using-opencv)
