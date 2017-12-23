# 更换颜色空间{#tutorial_py_colorspaces_cn}

## 目标

- 在这一教程中，你将会学到如何将图像从一个颜色空间变换到另外一个，像BGR $\leftrightarrow$ Gray, BGR $\leftrightarrow$ HSV等等。
- 另外，我们还将编写一个程序来从一段视频中提取出一个有颜色的物体。
- 你会学到这些函数：`cv2.cvtColor()`、`cv2.inRange()`等等。

## 更换颜色空间

OpenCV中有150多种颜色空间转换方法。 但是我们只会详细研究最广泛使用的两个，BGR $\leftrightarrow$ Gray和BGR $\leftrightarrow$ HSV。

要颜色转换，我们可以使用函数`cv2.cvtColor(input_image,flag)`，其中`flag`确定了转换的类型。

对于BGR $\rightarrow$Gray转换，我们使用flag`cv2.COLOR_BGR2GRAY`。 同样对于BGR$\rightarrow$HSV，我们使用flag`cv2.COLOR_BGR2HSV`。 要获得其他flag，只需在Python控制台中运行以下命令：

```python
>> import cv2
>> flags = [i for i in dir(cv2) if i.startswith('COLOR_')]
>> print( flags )
```

对于HSV，色调范围是[0,179]，饱和度范围是[0,255]，色值范围是[0,255]。

不同的软件使用不同的比例。 因此，如果你正在将OpenCV得到的值和它们的值比较，你需要规范化这些范围。

## 物体追踪

现在我们知道如何将BGR图像转换为HSV了，我们可以使用这个方法来提取一个有色物体。 在HSV颜色空间中，表现颜色比在BGR颜色空间中更容易。 在我们的应用程序中，我们将尝试提取一个蓝色的对象。 下面是方法：

- 得到视频的每一帧
- 从BGR转换到HSV色彩空间
- 我们将HSV图像限定为（一定范围内的）蓝色
- 现在单独提取蓝色的对象，我们可以对任何我们想要的图像这样做。

下面是有详细注释的代码：

```python
import cv2
import numpy as np

cap = cv2.VideoCapture(0)

while(1):
    # 获取每一帧
    _, frame = cap.read()
    # BGR转HSV
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    # 在HSV空间中定义蓝色
    lower_blue = np.array([110,50,50])
    upper_blue = np.array([130,255,255]) 
    # 从HSV图片中截取出蓝色
    mask = cv2.inRange(hsv, lower_blue, upper_blue)
    # 将原图像和mask进行按位与
    res = cv2.bitwise_and(frame,frame, mask= mask)
    cv2.imshow('frame',frame)
    cv2.imshow('mask',mask)
    cv2.imshow('res',res)
    k = cv2.waitKey(5) & 0xFF
    if k == 27:
        break

cv2.destroyAllWindows()
```

下面的图片展示了追踪蓝色的物体的结果：

![image](images/frame.jpg)

图像中有一些噪音。 我们将在后面的章节中看到如何移除它们。

这是对象跟踪中最简单的方法。 一旦你学习了如何找到轮廓，你可以做很多事情，如找到这个对象的质心，并使用它来跟踪对象，在相机前面移动你的手来绘制图表等，还有许多其他有趣的东西可以做。

## 如何找到要跟踪的HSV值？

这是[stackoverflow.com](http://www.stackoverflow.com)上的常见问题。 这非常简单，你可以使用相同的函数`cv2.cvtColor()`。 您只需传递您想要的BGR值，而不是传递图像。 例如，要查找Green的HSV值，试试看在Python控制台中执行以下命令：

```python
>>> green = np.uint8([[[0,255,0 ]]])
>>> hsv_green = cv2.cvtColor(green,cv2.COLOR_BGR2HSV)
>>> print( hsv_green ) # [[[ 60 255 255]]]
```

现在分别取[H-10,100,100]和[H + 10,255,255]作为下限和上限。 除了这种方法以外，你可以使用任何图像编辑工具，如GIMP或任何在线转换器来找到这些值，但不要忘记调整HSV范围。

## 练习

尝试找到一种方法来提取多个有色物体，例如，同时提取红色，蓝色，绿色物体。