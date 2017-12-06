# 图像梯度{#tutorial_py_gradients_cn}

## 目标

在这一章中，我们将学习：

- 查找图像梯度，边缘等。
- 我们将学习以下函数：`cv2.Sobel()`，`cv2.Scharr()`，`cv2.Laplacian()`等。

## 理论基础

### 1. Sobel和Scharr导数

Sobel算子是一个联合了Gausssian平滑和差分的运算，因此它更能抵抗噪声。 您可以指定要取导数的方向，垂直或者水平（分别通过参数`yorder`和`xorder`）。 你也可以通过参数`ksize`来指定内核的大小。 如果ksize = -1，则使用3x3 Scharr滤波器，其结果比3x3 Sobel滤波器更好。 请参阅所用内核的文档。

### 2. 拉普拉斯导数

它计算由 $\Delta src = \frac{\partial ^2{src}}{\partial x^2} + \frac{\partial ^2{src}}{\partial y^2}$给出的图像的拉普拉斯算子，其中每个导数都是用Sobel导数计算的，如果`ksize=1`，则使用以下内核进行过滤：
$$
kernel = \begin{bmatrix} 0 & 1 & 0 \\ 1 & -4 & 1 \\ 0 & 1 & 0  \end{bmatrix}
$$

## 代码

下面的代码在单个图表中显示了所有操作的运算结果。 所有内核都是5x5大小。 输出图像的深度传递-1以得到`np.uint8`类型的结果。

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('dave.jpg',0)
laplacian = cv2.Laplacian(img,cv2.CV_64F)
sobelx = cv2.Sobel(img,cv2.CV_64F,1,0,ksize=5)
sobely = cv2.Sobel(img,cv2.CV_64F,0,1,ksize=5)
plt.subplot(2,2,1),plt.imshow(img,cmap = 'gray')
plt.title('Original'), plt.xticks([]), plt.yticks([])
plt.subplot(2,2,2),plt.imshow(laplacian,cmap = 'gray')
plt.title('Laplacian'), plt.xticks([]), plt.yticks([])
plt.subplot(2,2,3),plt.imshow(sobelx,cmap = 'gray')
plt.title('Sobel X'), plt.xticks([]), plt.yticks([])
plt.subplot(2,2,4),plt.imshow(sobely,cmap = 'gray')
plt.title('Sobel Y'), plt.xticks([]), plt.yticks([])
plt.show()
```

结果如下：

![image](images/gradients.jpg)

## 一件重要的事

在我们的最后一个例子中，输出数据类型是`cv2.CV_8U`或`np.uint8`。 但是有一个小问题。 黑白转换为正斜率（正值），白转黑转换为负斜率（负值）。 所以当你把数据转换成np.uint8时，所有的负斜率都会变成零。 简而言之，你会忽略了这个边缘。

如果黑到白和白到黑两边你都想检测，更好的选择是保持输出数据类型的一些更多位数的形式，如`cv2.CV16S`，`cv2.CV64F`等，取其绝对值，然后转换回`cv2.CV_8U`。

下面的代码演示了水平Sobel滤波器的这个过程和结果的差异。

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('box.png',0)

# Output dtype = cv2.CV_8U
sobelx8u = cv2.Sobel(img,cv2.CV_8U,1,0,ksize=5)

# Output dtype = cv2.CV_64F. Then take its absolute and convert to cv2.CV_8U
sobelx64f = cv2.Sobel(img,cv2.CV_64F,1,0,ksize=5)
abs_sobel64f = np.absolute(sobelx64f)
sobel_8u = np.uint8(abs_sobel64f)

plt.subplot(1,3,1),plt.imshow(img,cmap = 'gray')
plt.title('Original'), plt.xticks([]), plt.yticks([])
plt.subplot(1,3,2),plt.imshow(sobelx8u,cmap = 'gray')
plt.title('Sobel CV_8U'), plt.xticks([]), plt.yticks([])
plt.subplot(1,3,3),plt.imshow(sobel_8u,cmap = 'gray')
plt.title('Sobel abs(CV_64F)'), plt.xticks([]), plt.yticks([])

plt.show()
```

下面是结果：

![image](images/double_edge.jpg)

