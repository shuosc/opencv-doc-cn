# 背景分割{#tutorial_py_bg_subtraction_cn}

## 目标

在这一章当中，

- 我们将熟悉OpenCV中的背景分割方法。

## 基本知识

背景分割是许多基于视觉的应用程序中的主要预处理步骤。例如，考虑访客计数器，利用固定的摄像头统计访客进入和离开房间的数量，或利用交通摄像机提取有关车辆等信息的情况。在所有这些情况下，首先需要单独提取人员或车辆。从技术上讲，你需要从静态背景提取移动的前景。

如果已经有了背景图像，如没有游客的房间图像，没有车辆的道路图像等，这是一件容易的事情。只需从背景中减去新的图像。你就能得到前景物体。但在大多数情况下，您可能没有这样的图像，所以我们需要从我们拥有的任何图像中提取背景。车辆有阴影时变得更加复杂。由于阴影也在移动，简单的减法将会将其标记为前景。这使事情变得复杂。

为此目的引入了几种算法。 OpenCV已经实现了三个非常容易使用的算法。我们会一一看到他们。

### BackgroundSubtractorMOG

这是一个基于高斯混合的背景/前景分割算法。它是在P. KadewTraKuPong和R. Bowden于2001年在《An improved adaptive background mixture model for real-time tracking with shadow detection》一文中介绍的。它使用一种方法来模拟每个背景像素的混合K个高斯分布（ K为3到5）。混合物的权重表示这些颜色留在场景中的时间比例。可能的背景颜色是保持更长和更静态的颜色。

在编码时，我们需要使用函数`cv2.createBackgroundSubtractorMOG()`创建一个背景对象。它有一些可选的参数，如历史长度，高斯混合的数量，阈值等。它们都被设置为一些默认值。然后在视频循环中，使用`backgroundsubtractor.apply()`方法获取前景mask。

看一个简单的例子如下：

```python
import numpy as np
import cv2

cap = cv2.VideoCapture('vtest.avi')
fgbg = cv2.createBackgroundSubtractorMOG()
while(1):
    ret, frame = cap.read()
    fgmask = fgbg.apply(frame)
    cv2.imshow('frame',fgmask)
    k = cv2.waitKey(30) & 0xff
    if k == 27:
        break
cap.release()
cv2.destroyAllWindows()
```

（所有算法的结果都显示在最后以便互相比较）

### BackgroundSubtractorMOG2

这也是一个基于高斯混合的背景/前景分割算法。它基于Z.Zivkovic在2004年发表的两篇论文《Improved adaptive Gausian mixture model for background subtraction》以及2006年的《Efficient Adaptive Density Estimation per Image Pixel for the Task of Background Subtraction》。该算法的一个重要特征是它为每个像素选择适当数量的高斯分布。 （请记住，在上一个例子中，我们在整个算法中采用了恒定的K个高斯分布）。它提供更好的适应变化的场景由于照明变化等。

和以前的情况一样，我们必须创建一个背景减法器对象。在这里，您可以选择是否检测阴影。如果`detectShadows = True`（默认情况下是这样），它会检测并标记阴影，但会降低速度。阴影将被标记为灰色。

```python
import numpy as np
import cv2

cap = cv2.VideoCapture('vtest.avi')

fgbg = cv2.createBackgroundSubtractorMOG2()

while(1):
    ret, frame = cap.read()

    fgmask = fgbg.apply(frame)

    cv2.imshow('frame',fgmask)
    k = cv2.waitKey(30) & 0xff
    if k == 27:
        break

cap.release()
cv2.destroyAllWindows()
```
（结果在最后）

### BackgroundSubtractorGMG

该算法将统计背景图像估计和每像素贝叶斯分割相结合。这是由Andrew B. Godbehere，Akihiro Matsukawa，Ken Goldberg在2012年发表的《Visual Tracking of Human Visitors under Variable-Lighting Conditions for a Responsive Audio Art Installation》一文中介绍的一种响应式音频艺术装置。本文根据该论文，系统运行了一个成功的交互式音频艺术装置于2011年3月31日至31日在加利福尼亚旧金山当代犹太博物馆举行，名为“我们还在吗？”。

它使用前几个（默认为120）帧进行背景建模。它采用概率前景分割算法，使用贝叶斯推理来识别可能的前景对象。这个识别是适应性的，较新的观察值比旧的观察值更重，以适应可变照明。使用了闭合和开启几个形态学操作，以消除不必要的噪音。前几帧你会看到一个黑色的窗口。

将形态学开启应用于结果以消除噪音会更好。

```python
import numpy as np
import cv2

cap = cv2.VideoCapture('vtest.avi')

kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(3,3))
fgbg = cv2.createBackgroundSubtractorGMG()

while(1):
    ret, frame = cap.read()

    fgmask = fgbg.apply(frame)
    fgmask = cv2.morphologyEx(fgmask, cv2.MORPH_OPEN, kernel)
    
    cv2.imshow('frame',fgmask)
    k = cv2.waitKey(30) & 0xff
    if k == 27:
        break

cap.release()
cv2.destroyAllWindows()
```

### 结果

**原始的图片**

下面是视频的第200帧。

![image](images/resframe.jpg)

**BackgroundSubtractorMOG的结果**

![image](images/resmog.jpg)

**BackgroundSubtractorMOG的结果**

灰色显示阴影区域。

![image](images/resmog2.jpg)

**Result of BackgroundSubtractorGMG**

用形态学开放删除。

![image](images/resgmg.jpg)

