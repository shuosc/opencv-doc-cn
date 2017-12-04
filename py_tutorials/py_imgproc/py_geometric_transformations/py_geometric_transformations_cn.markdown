# 对图像进行几何变换{#tutorial_py_geometric_transformations_cn}

## 目标

- 学习对图像应用不同的几何变换，如平移，旋转，仿射变换等。
- 你会学到这些函数：`cv2.getPerspectiveTransform`

## 变换

OpenCV提供了两个转换函数，`cv2.warpAffine`和`cv2.warpPerspective`，可以进行各种转换。 `cv2.warpAffine`采用2x3变换矩阵，而`cv2.warpPerspective`采用3x3变换矩阵作为输入。

### 缩放

缩放只是调整图像的大小。 OpenCV为此提供了一个函数`cv2.resize()`。 图像的大小可以手动指定，也可以指定比例因子。

可以使用不同的插值方法。 优选的插值方法是用`cv2.INTER_AREA`缩小，`cv2.INTER_CUBIC`（慢）和用`cv2.INTER_LINEAR`来放大。 默认情况下，所有调整大小的插值方法都是`cv2.INTER_LINEAR`。 您可以使用以下方法调整输入图像大小：

```python
import cv2
import numpy as np
img = cv2.imread('messi5.jpg')
res = cv2.resize(img,None,fx=2, fy=2, interpolation = cv2.INTER_CUBIC)
# 或者
height, width = img.shape[:2]
res = cv2.resize(img,(2width, 2height), interpolation = cv2.INTER_CUBIC)
```

### 平移

平移就是移动对象的位置。 如果你知道了$(x,y)$方向上移动的距离，假设它是$(t_x,t_y)$，则可以创建如下的变换矩阵$\textbf {M}$：

$$
M = \begin{bmatrix} 1 & 0 & t_x \\ 0 & 1 & t_y  \end{bmatrix}
$$

你可以把它变成np.float32类型的Numpy数组，并将它传递给`cv2.warpAffine()`函数。 看下面移动$(100,50)$的例子：

```python
import cv2
import numpy as np

img = cv2.imread('messi5.jpg',0)
rows,cols = img.shape
M = np.float32([[1,0,100],[0,1,50]])
dst = cv2.warpAffine(img,M,(cols,rows))
cv2.imshow('img',dst)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

**警告**

`cv2.warpAffine()`函数的第三个参数是输出图像的大小，它应该是(width,height)的形式。 记住width=列数，height=行数。

下面是平移的结果：

![image](images/translation.jpg)

### 旋转

通过如下形式的变换矩阵来实现旋转角度为$\theta$的图像旋转:
$$
M = \begin{bmatrix} cos\theta & -sin\theta \\ sin\theta & cos\theta   \end{bmatrix}
$$
OpenCV提供了可调整旋转中心的缩放旋转，以便您可以在任何您喜欢的位置旋转。 修改后的变换矩阵由下式给出：
$$
\begin{bmatrix} \alpha &  \beta & (1- \alpha )  \cdot center.x -  \beta \cdot center.y \\ - \beta &  \alpha &  \beta \cdot center.x + (1- \alpha )  \cdot center.y \end{bmatrix} 
\\
where
\\
\begin{array}{l} \alpha =  scale \cdot \cos \theta , \\ \beta =  scale \cdot \sin \theta \end{array}
$$
为了找到这个转换矩阵，OpenCV提供了一个函数cv2.getRotationMatrix2D。 请看下面的例子，它将图像相对于中心旋转90度，而没有任何缩放。

### 仿射变换

在仿射变换中，原始图像中的所有平行线在输出图像中仍然是平行的。 为了找到变换矩阵，我们需要输入图像中的三个点和它们在输出图像中的相应位置。 然后`cv2.getAffineTransform`将创建一个2x3矩阵，将其传递给`cv2.warpAffine`。

看下面的例子，并看看我选择的点（用绿色标记）：

```python
img = cv2.imread('drawing.png')
rows,cols,ch = img.shape
pts1 = np.float32([[50,50],[200,50],[50,200]])
pts2 = np.float32([[10,100],[200,50],[100,250]])
M = cv2.getAffineTransform(pts1,pts2)
dst = cv2.warpAffine(img,M,(cols,rows))
plt.subplot(121),plt.imshow(img),plt.title('Input')
plt.subplot(122),plt.imshow(dst),plt.title('Output')
plt.show()
```

下面是结果：

![image](images/affine.jpg)

### 透视变换

对于透视变换，您需要一个3x3变换矩阵。 即使在变换之后，直线仍为直线。 要找到这个变换矩阵，你需要输入图像上的4个点和输出图像上的对应点。 在这4点中，应该不存在三点共线。 然后可以通过函数`cv2.getPerspectiveTransform`找到变换矩阵。 然后将`cv2.warpPerspective`应用于这个3x3转换矩阵。

请看下面的代码：

```python
img = cv2.imread('sudoku.png')
rows,cols,ch = img.shape
pts1 = np.float32([[56,65],[368,52],[28,387],[389,390]])
pts2 = np.float32([[0,0],[300,0],[0,300],[300,300]])
M = cv2.getPerspectiveTransform(pts1,pts2)
dst = cv2.warpPerspective(img,M,(300,300))
plt.subplot(121),plt.imshow(img),plt.title('Input')
plt.subplot(122),plt.imshow(dst),plt.title('Output')
plt.show()
```

结果如下：

![image](images/perspective.jpg)

## 更多资源

[Computer Vision: Algorithms and Applications](https://books.google.com/books?hl=zh-CN&lr=&id=bXzAlkODwa8C&oi=fnd&pg=PR4&dq=Computer+Vision:+Algorithms+and+Applications&ots=g_Y470nDCF&sig=iFX7bOCsAefVolxa9Yk0fIC-HQc#v=onepage&q=Computer%20Vision%3A%20Algorithms%20and%20Applications&f=false)

