# 用鼠标做画笔{#tutorial_py_mouse_handling_cn}

## 目标

- 学会如何使用OpenCV处理鼠标事件
- 你会学到这些函数：`cv2.setMouseCallback()`

## 简单的展示

在这里，我们创建一个简单的应用程序，在我们双击的图像位置上绘制一个圆圈。

首先我们创建一个鼠标事件发生时执行的回调函数。 鼠标事件可以是任何与鼠标有关的东西，例如左键点击，左键抬起，左键双击等。它会传给我们每个鼠标事件的坐标(x,y)。 有了这个事件和位置，我们可以做任何我们想要做的事情。 要列出所有可用的事件，请在Python终端中运行以下代码：

```python
import cv2
events = [i for i in dir(cv2) if 'EVENT' in i]
print(events)
```

创建鼠标回调函数有一个特定的格式，到哪里都是一样的。 仅仅在功能上有所不同。 我们的鼠标回调函数只做了一件事，它在我们双击的地方绘制一个圆圈。 看下面的代码：

```python
import cv2
import numpy as np

# 鼠标回调函数
def draw_circle(event,x,y,flags,param):
    if event == cv2.EVENT_LBUTTONDBLCLK:
        cv2.circle(img,(x,y),100,(255,0,0),-1)

# 创建一个内容为黑色图片的窗口，将函数绑定到窗口上
img = np.zeros((512,512,3), np.uint8)
cv2.namedWindow('image')
cv2.setMouseCallback('image',draw_circle)

while(1):
    cv2.imshow('image',img)
    if cv2.waitKey(20) & 0xFF == 27:
        break
cv2.destroyAllWindows()
```

## 更进一步的展示

现在我们来做一个更好的应用程序。 在这里，我们通过像在Paint应用程序中一样拖动鼠标来绘制矩形或圆形（取决于我们选择的模式）。 所以我们的鼠标回调函数有两个部分，一个画矩形，另一个画圆。 这个具体的例子对于创建和理解对象跟踪，图像分割等一些交互式应用程序非常有帮助。

```python
import cv2
import numpy as np

drawing = False # 鼠标按下后为True
mode = True # 如果为True, 画矩形。按'm'键转换为画圆
ix,iy = -1,-1

# 鼠标回调函数
def draw_circle(event,x,y,flags,param):
    global ix,iy,drawing,mode

    if event == cv2.EVENT_LBUTTONDOWN:
        drawing = True
        ix,iy = x,y
    
    elif event == cv2.EVENT_MOUSEMOVE:
        if drawing == True:
            if mode == True:
                cv2.rectangle(img,(ix,iy),(x,y),(0,255,0),-1)
            else:
                cv2.circle(img,(x,y),5,(0,0,255),-1)
    
    elif event == cv2.EVENT_LBUTTONUP:
        drawing = False
        if mode == True:
            cv2.rectangle(img,(ix,iy),(x,y),(0,255,0),-1)
        else:
            cv2.circle(img,(x,y),5,(0,0,255),-1)
```

接下来，我们必须将这个鼠标回调函数绑定到OpenCV窗口。 在主循环中，我们应该为键'm'设置键盘绑定，以在矩形和圆形之间切换。

```python
img = np.zeros((512,512,3), np.uint8)
cv2.namedWindow('image')
cv2.setMouseCallback('image',draw_circle)

while(1):
    cv2.imshow('image',img)
    k = cv2.waitKey(1) & 0xFF
    if k == ord('m'):
        mode = not mode
    elif k == 27:
        break

cv2.destroyAllWindows()
```

## 练习

在我们的最后一个例子中，我们绘制的是填充过的矩形。 请您修改代码以绘制未填充的矩形。