# 霍夫圆变换{#tutorial_py_houghcircles_cn}

## 目标

在这一章当中，
- 我们将学习使用霍夫变换来查找图像中的圆。
- 我们将看到这些函数：`cv2.HoughCircles()`

## 理论基础

一个圆在数学上可以表示为$(x-x_{center})^2 + (y - y_{center})^2 = r^2$其中$(x_{center},y_{center})$是圆的中心，$ r $是圆的半径。从等式中可以看出我们有3个参数，所以我们需要一个三维累加器来进行霍夫变换，这么做的效率非常差。所以OpenCV使用更复杂的方法，**Hough Gradient Method**，它使用边缘的渐变信息。

我们在这里使用的函数是`cv2.HoughCircles()`。它有很多参数，在文档中有很好的解释。所以我们直接上代码。

```python
import cv2
import numpy as np

img = cv2.imread('opencv-logo-white.png',0)
img = cv2.medianBlur(img,5)
cimg = cv2.cvtColor(img,cv2.COLOR_GRAY2BGR)

circles = cv2.HoughCircles(img,cv2.HOUGH_GRADIENT,1,20,param1=50,param2=30,minRadius=0,maxRadius=0)


circles = np.uint16(np.around(circles))
for i in circles[0,:]:
    # 画出外面的圆
    cv2.circle(cimg,(i[0],i[1]),i[2],(0,255,0),2)
    # 画出圆心
    cv2.circle(cimg,(i[0],i[1]),2,(0,0,255),3)

cv2.imshow('detected circles',cimg)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

结果如下所示：

![image](images/houghcircles2.jpg)

