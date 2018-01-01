# 形态学转换{#tutorial_py_morphological_ops_cn}

## 目标

在这一章当中，

- 我们将学习不同的形态学操作，如腐蚀，膨胀，开启，闭合等。
- 我们将看到不同的功能，如：`cv2.erode()`，`cv2.dilate()`，`cv2.morphologyEx()`等。

## 理论基础

形态转换是基于图像形状的一些简单操作。它通常在二值图像上执行。它需要两个输入，一个是我们的原始图像，另一个是决定操作性质的结构元素或内核。两个基本的形态学操作是腐蚀和膨胀。它们的变体形式，如打开，关闭，梯度等也会发挥很大作用。我们将在下面的图片的帮助下逐一看到他们：

![image](images/j.png)

### 1. 腐蚀

腐蚀的基本思想就像土壤被侵蚀，它“腐蚀”了前景物体的边界（记得要总是试图保持前景为白色）。那么它做了什么？内核在图像中滑动（就像2D卷积重那样）。只有当内核下的所有像素都是1时，原始图像（1或0）中的一个像素才会被视为1，否则会被“腐蚀”（置零）。

这样做会导致图像发生什么样的变化呢？边界附近的所有像素都将被丢弃，这取决于内核的大小。所以前景物体的厚度或尺寸会减小，或者说图像中的白色区域会减小。这在去除小的白色噪音（正如我们在颜色空间章节看到的那样）、分离两个连接的物体等场合下非常有用。

在这里，作为一个例子，我将使用一个5x5的全1内核。让我们看看它是如何工作的：

```python
import cv2
import numpy as np

img = cv2.imread('j.png',0)
kernel = np.ones((5,5),np.uint8)
erosion = cv2.erode(img,kernel,iterations = 1)
```

结果如下：

![image](images/erosion.png)

### 2. 膨胀

膨胀是的腐蚀的逆操作。如果内核下的至少一个像素是“1”，则该像素元素是“1”。所以它增加了图像中的白色区域或者说增加了前景物体的大小。

通常情况下，在要消除噪音的情况下，会连着使用腐蚀和膨胀。因为腐蚀消除了白色的噪音，但它也缩小了我们的对象。所以我们要再对其进行膨胀。由于噪音已经消失了，他们不会再回来，但我们的对象面积会再增加回来。膨胀在连接对象的破碎部分时也很有用。

```python
dilation = cv2.dilate(img,kernel,iterations = 1)
```

结果如下：

![image](images/dilation.png)

### 3. 开启

开启只是腐蚀之后再膨胀的另一个名称。正如我们上面所解释的那样，它有助于消除噪音。这里我们使用函数`cv2.morphologyEx()`：

```python
opening = cv2.morphologyEx(img, cv2.MORPH_OPEN, kernel)
```

结果如下：

![image](images/opening.png)

### 4. 闭合

闭合是开启的逆操作，先膨胀再腐蚀。在“闭合”前景物体上的小孔或物体上的小黑点时非常有用。

```python
closing = cv2.morphologyEx(img, cv2.MORPH_CLOSE, kernel)
```

结果如下：

![image](images/closing.png)

### 5. 形态学梯度

是一个图像的膨胀和侵蚀后的差值。

结果将看起来像对象的轮廓。

```python
gradient = cv2.morphologyEx（img，cv2.MORPH_GRADIENT，kernel）
```

结果：

![image](images/gradient.png)

### 6. 顶帽

是输入图像和开启后图像的差值。下面的例子是由9x9内核完成的。

```python
tophat = cv2.morphologyEx(img, cv2.MORPH_TOPHAT, kernel)
```

结果：

![image](images/tophat.png)

### 7. 黑帽

是输入图像和闭合后图像的差值。

```python
blackhat = cv2.morphologyEx(img, cv2.MORPH_BLACKHAT, kernel)
```

结果：

![image](images/blackhat.png)

## 结构元素

在Numpy的帮助下，我们在前面的例子中手动创建了一个结构元素。它是矩形的。但在某些情况下，您可能需要椭圆形/圆形的内核。为此，OpenCV有一个函数`cv2.getStructuringElement()`。你只需要传入所需内核的形状和大小，你会得到你要的内核。

```python
# 矩形内核
>>> cv2.getStructuringElement(cv2.MORPH_RECT,(5,5))
>>> array([[1, 1, 1, 1, 1],
       [1, 1, 1, 1, 1],
       [1, 1, 1, 1, 1],
       [1, 1, 1, 1, 1],
       [1, 1, 1, 1, 1]], dtype=uint8)

# 椭圆内核
>>> cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5))
>>> array([[0, 0, 1, 0, 0],
       [1, 1, 1, 1, 1],
       [1, 1, 1, 1, 1],
       [1, 1, 1, 1, 1],
       [0, 0, 1, 0, 0]], dtype=uint8)

# 十字形内核
>>> cv2.getStructuringElement(cv2.MORPH_CROSS,(5,5))
>>> array([[0, 0, 1, 0, 0],
       [0, 0, 1, 0, 0],
       [1, 1, 1, 1, 1],
       [0, 0, 1, 0, 0],
       [0, 0, 1, 0, 0]], dtype=uint8)
```

## 更多资源

- [形态学操作](http://homepages.inf.ed.ac.uk/rbf/HIPR2/morops.htm)

