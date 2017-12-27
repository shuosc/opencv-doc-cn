# 平滑图像 {#tutorial_py_filtering_cn}

## 目标

学习：

- 用各种低通滤波器模糊图像
- 将定制过滤器应用于图像（二维卷积）

## 二维卷积（图像过滤）

与一维信号一样，图像也可以用各种低通滤波器（LPF），高通滤波器（HPF）等进行滤波。LPF有助于消除噪声，模糊图像等。HPF滤波器有助于找到图片的边缘。

OpenCV提供了一个函数`cv2.filter2D()`来将一个内核与一个图像进行卷积。作为例子，我们将尝试在图像上使用平均过滤器。一个5x5的平均滤波器内核如下所示：
$$
K =  \frac{1}{25} \begin{bmatrix} 1 & 1 & 1 & 1 & 1 \\ 1 & 1 & 1 & 1 & 1 \\ 1 & 1 & 1 & 1 & 1 \\1 & 1 & 1 & 1 & 1 \\ 1 & 1 & 1 & 1 & 1 \end{bmatrix}
$$
滤波的过程是这样的：将该卷积核的中心放在一个像素之上，将该卷积核之下的所有25个像素加起来，取其平均值，用新的平均值代替中心像素。它会对图像中的所有像素执行此操作。试试这个代码并查看结果：

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('opencv_logo.png')
kernel = np.ones((5,5),np.float32)/25
dst = cv2.filter2D(img,-1,kernel)
plt.subplot(121),plt.imshow(img),plt.title('Original')
plt.xticks([]), plt.yticks([])
plt.subplot(122),plt.imshow(dst),plt.title('Averaging')
plt.xticks([]), plt.yticks([])
plt.show()
```

结果：

![image](images/filter.jpg)

## 图像模糊化（图像平滑）

图像模糊化是通过将图像与低通滤波器内核进行卷积来实现的。消除噪音非常有用。它实际上是从图像中去除了高频内容（例如：噪声，边缘）。所以这个操作会使边缘模糊一点。 （好吧，有些模糊化的技术也不会模糊边缘）。 OpenCV主要提供四种模糊技术。

### 1. 平均值法

这是通过使用归一化的box过滤器进行图像卷积来完成的。它只取卷积核的区域内所有像素的平均值，并替换中心元素。这是由函数`cv2.blur()`或`cv2.boxFilter()`完成的。查看文档以获取关于卷积核的更多细节。我们应该指定内核的宽度和高度。一个3x3归一化box过滤器如下所示：
$$
K =  \frac{1}{9} \begin{bmatrix} 1 & 1 & 1  \\ 1 & 1 & 1 \\ 1 & 1 & 1 \end{bmatrix}
$$


如果您不想使用归一化的box过滤器，请使用`cv2.boxFilter()`。将参数`normalize = False`传递给函数。

下面是使用5x5大小的卷积核的例子：

```python
import cv2
import numpy as np

from matplotlib import pyplot as plt
img = cv2.imread('opencv-logo-white.png')
blur = cv2.blur(img,(5,5))
plt.subplot(121),plt.imshow(img),plt.title('Original')
plt.xticks([]), plt.yticks([])
plt.subplot(122),plt.imshow(blur),plt.title('Blurred')
plt.xticks([]), plt.yticks([])
plt.show()
```

结果如下：

![image](images/blur.jpg)

### 2. 高斯模糊法

这个方法使用高斯核而不是box过滤器。它是用函数`cv2.GaussianBlur()`完成的。我们需要指定内核的宽度和高度，这两个值应该是正的奇数。我们还应该分别指定X和Y方向的标准差`sigmaX`和`sigmaY`。如果只指定`sigmaX`，则默认`sigmaY`与`sigmaX`相同。如果两者都是零，则会从从内核大小计算出来。高斯模糊对于从图像中去除高斯噪声非常有效。

如果需要，可以使用函数`cv2.getGaussianKernel()`创建一个高斯内核。

上面的代码可以修改为使用高斯模糊：

```python
blur = cv2.GaussianBlur(img,(5,5),0)
```

结果如下：

![image](images/gaussian.jpg)

### 3. 中位数模糊法

在这里，函数`cv2.medianBlur()`取卷积核区域下的所有像素的中位数，中心元素被这个中值取代。这对于图像中的“椒盐噪音”非常有效。有趣的是，在前面说的两个滤波器中，中心元素是新计算的值，它可以等于图像中的像素值或者就是新的值。但是在中值模糊的情况下，中心元素总是被图像中的某个像素值替代。它有效地降低了噪音。它的内核大小应该是一个正奇数。

在这个演示中，我添加了50％的噪声，我们的原始图像和应用中位模糊。看看结果：

```python
median = cv2.medianBlur(img,5)
```

结果如下：

![image](images/median.jpg)

### 4. 双边过滤法

`cv2.bilateralFilter()`在消除噪音方面非常有效，同时它能保持边缘清晰。但与其他过滤器相比速度较慢。我们已经看到，高斯滤波器取像素周围的一个邻域，并找到它的高斯加权平均值。这个高斯滤波器是空间独立的函数，也就是在滤波时考虑了附近所有的像素。它不考虑像素是否具有几乎相同的强度。它不考虑像素是否是边缘像素。所以它也模糊了我们不想模糊的边缘。

双边滤波器也需要使用一个空间中的高斯滤波器，而另外一个高斯滤波器是像素差的函数。空间的高斯函数确保在模糊时只考虑附近的像素，而亮度差异高斯函数确保那些与中心像素具有相似亮度的像素才被认为是需要被模糊的。所以它会保留边缘，因为在边缘的像素将具有较大的亮度变化。

以下示例显示使用双边过滤器（有关参数的详细信息，请查阅文档）。

```python
blur = cv2.bilateralFilter(img,9,75,75)
```

结果：

![image](images/bilateral.jpg)

看，图像表面上的纹理消失了，但边缘仍然清晰。

## 其他资源
- [关于双边过滤的详细信息](http://people.csail.mit.edu/sparis/bf_course/)