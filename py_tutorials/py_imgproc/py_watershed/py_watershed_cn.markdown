# 基于分水岭算法的图像分割{#tutorial_py_watershed_cn}

## 目标

在这一章当中，
- 我们将学习使用基于标记的分水岭算法来进行图像分割
- 我们将看到：`cv2.watershed()`

## 理论基础

任何灰度图像可以被看作是一个地形表面，其中高强度表示峰和山，而低强度表示山谷。你开始用不同颜色的水（标签）填充每个孤立的山谷（局部最小值）。随着水位上升，根据附近的山峰（梯度），来自不同山谷的水，明显不同的颜色将开始合并。为了避免这种情况，你在水合并的地方建立障碍。你继续填充水和筑垒的工作，直到所有的高峰在水之下。然后你创建的障碍将会给你的分割的结果。这是分水岭背后的“哲学”。你可以访问[CMM分水岭网页](http://cmm.ensmp.fr/~beucher/wtshed.html)来了解一些动画的帮助。

但是这种方法会在图像中存在噪声或任何其他不规则之处过度分割。所以OpenCV实现了一个基于标记的分水岭算法，你可以指定哪些谷点将被合并，哪些不会。这是一个交互式图像分割。我们所需要做的就是为我们所知的对象赋予不同的标签。用一种颜色（或强度）标记我们确定为前景或对象的区域，用另一种颜色标记我们确定为背景或非对象的区域，最后用0来标记我们不确定的区域。然后应用分水岭算法。然后我们的标记将更新为我们给出的标签，对象的边界值将为-1。

## 代码

下面我们将看到一个关于如何使用距离变换和分水岭来分割相互接触的对象的例子。
考虑下面的硬币图像，硬币互相接触。即使你进行了二值化，它也会触及对方。

![image](images/water_coins.jpg)

我们首先找到硬币的大致分割。为此，我们可以使用Otsu二值化。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt

img = cv2.imread('coins.png')
gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
ret, thresh = cv2.threshold(gray,0,255,cv2.THRESH_BINARY_INV+cv2.THRESH_OTSU)
```

结果：

![image](images/water_thresh.jpg)

现在我们需要去除图像中的任何小的白色噪音。为此，我们可以使用形态学开启。要删除对象中的任何小孔，我们可以使用形态学闭合。所以，现在我们可以肯定，靠近物体中心的区域是前景区域，远离物体的区域是背景。只有我们不确定的地区是硬币的边界地区。

所以我们需要提取我们确信它们是硬币的区域。腐蚀消除了边界像素。所以，无论剩下什么，我们可以肯定这是硬币。如果物体不相互接触，那将是有效的。但是由于它们彼此接触，另一个好的选择是找到距离变换并应用适当的阈值。接下来我们需要找到我们确信他们不是硬币的区域。为此，我们对结果进行膨胀操作。膨胀将对象边界向背景方向增加。这样，我们可以确定结果背景中的任何区域是真正的背景，因为边界区域被删除了。看到下面的图片。

![image](images/water_fgbg.jpg)

其余的地区是我们对其是硬币还是背景一无所知的地方。分水岭算法应该会找到它。这些区域通常在前景和背景相遇的硬币的边界附近（或者甚至是两个不同的硬币相遇）。我们称之为边界。它可以通过从sure_bg区域中减去sure_fg区域来获得。

```python
# 噪音消除
kernel = np.ones((3,3),np.uint8)
opening = cv2.morphologyEx(thresh,cv2.MORPH_OPEN,kernel, iterations = 2)

# 确定的背景区域
sure_bg = cv2.dilate(opening,kernel,iterations=3)

# 找到确定的前景区域
dist_transform = cv2.distanceTransform(opening,cv2.DIST_L2,5)
ret, sure_fg = cv2.threshold(dist_transform,0.7*dist_transform.max(),255,0)

# 找到不确定的区域
sure_fg = np.uint8(sure_fg)
unknown = cv2.subtract(sure_bg,sure_fg)
```

看结果。在这个二值化的图像中，我们得到了一些硬币的区域，我们确信这些硬币是现在被分离的。 （在某些情况下，您可能只对前景分割感兴趣，而不是分离相互接触的对象，这种情况下，不需要使用距离变换，只要侵蚀就足够了，侵蚀只是提取前景区域的另一种方法。）

![image](images/water_dt.jpg)

现在我们肯定地知道哪些是背景的区域，哪些是硬币的区域。所以我们创建标记（它是一个与原始图像大小相同的数组，但是是int32数据类型）并在其中标记区域。我们知道的区域（无论是前景还是背景）都可以使用用任何不同的正整数标记，我们不知道的区域使用零。为此我们使用`cv2.connectedComponents()`。它用0标记图像的背景，然后用从1开始的整数标记其他对象。

但是我们知道，如果背景标记为0，分水岭会将其视为未知区域。所以我们要用不同的整数来标记它。相反，我们将未知区域定义为unknown，用0表示。

```python
# 标记标签
ret, markers = cv2.connectedComponents(sure_fg)

# 为所有标签+1，以确保背景不是0，而是1
markers = markers+1

# 现在，用零标记未知区域
markers[unknown==255] = 0
```

查看JET颜色映射中显示的结果。深蓝色的地区显示未知的区域。硬币用不同的颜色着色。确定是背景的区域以浅蓝色显示。

![image](images/water_marker.jpg)

现在我们的标记已经准备就绪，现在是最后一步，应用分水岭算法的时候了。 然后标记图像将被修改。 边界区域将标记为-1。

```python
markers = cv2.watershed(img,markers)
img[markers == -1] = [255,0,0]
```

看下面的结果。对于一些硬币，他们所接触的区域被正确地分割，有些则不是这样。

![image](images/water_result.jpg)

## 更多资源

- 关于 [分水岭变换](http://cmm.ensmp.fr/~beucher/wtshed.html) 的CMM页面 

## 练习

- OpenCV样本具有分水岭分割的交互式样本watershed.py。运行它，享受它，然后学会它。