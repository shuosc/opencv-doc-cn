# 用滑块控制条做调色板{#tutorial_py_trackbar_cn}

## 目标

- 学习将滑块控制条绑定到OpenCV窗口
- 你将会学到这些函数：`cv2.getTrackbarPos()`、`cv2.createTrackbar()`等等。

## 代码示例

我们将创建一个简单的应用程序，显示您指定的颜色。您有一个显示颜色的窗口和三个用于指定B，G，R颜色的滑块控制条。您滑动滑块控制条并相应地更改窗口颜色。默认情况下，初始颜色将被设置为黑色。

对于`cv2.getTrackbarPos()`函数，第一个参数是trackbar名称，第二个参数是窗口名称，第三个参数是默认值，第四个参数是最大值，第五个参数是每次trackbar值改变时都会执行的回调函数。回调函数总是有一个默认的参数是trackbar的位置。在我们的例子中，函数什么都不做，所以我们只是`pass`。

trackbar的另一个重要应用是将其用作按钮或开关。 OpenCV默认情况下不具有按钮功能。所以你可以使用trackbar来获得这样的功能。在我们的应用程序中，我们创建了一个开关，应用程序只有在开关打开时才起作用，否则屏幕始终是黑色的。

```python
import cv2
import numpy as np

def nothing(x):
    pass

# 创建一张黑色图片和一个窗口
img = np.zeros((300,512,3), np.uint8)
cv2.namedWindow('image')

# 创建控制颜色的滑块控制条
cv2.createTrackbar('R','image',0,255,nothing)
cv2.createTrackbar('G','image',0,255,nothing)
cv2.createTrackbar('B','image',0,255,nothing)

# 创建ON/OFF的开关
switch = '0 : OFF \n1 : ON'
cv2.createTrackbar(switch, 'image',0,1,nothing)
while(1):
    cv2.imshow('image',img)
    k = cv2.waitKey(1) & 0xFF
    if k == 27:
        break
    
    # 获取滑块控制条的位置
    r = cv2.getTrackbarPos('R','image')
    g = cv2.getTrackbarPos('G','image')
    b = cv2.getTrackbarPos('B','image')
    s = cv2.getTrackbarPos(switch,'image')
    
    if s == 0:
        img[:] = 0
    else:
        img[:] = [b,g,r]

cv2.destroyAllWindows()
```

这个程序的截屏看起来像这样：

![image](images/trackbar_screenshot.jpg)

## 练习

使用滑块控制条创建一个具有可调颜色和画笔半径的Paint应用程序。 对于绘图，请参阅前面的鼠标处理的教程。