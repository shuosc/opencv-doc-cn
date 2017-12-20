# 开始使用图像{#tutorial_py_image_display_cn}

## 目标

- 在这里，你将会学到如何加载一副图像，如何显示它，如何保存它
- 你将会学到这些函数：`cv2.imread()`、`cv2.imshow()`、`cv2.imwrite()`
- 可选的，你会学到如何使用Matplotlib显示图像

## 使用OpenCV

### 读取一幅图像

使用`cv2.imread()`来读取一副图像。图像应该在工作目录下，否则就需要输入图像的完整目录。

使用Unix-based操作系统的同学请注意，在OpenCV中输入图像路径时`~`并不能用来指代家目录！

第二个参数是标记了应该以何种方式来读取图像的一个标志。

- `cv2.IMREAD_COLOR`：读取一副有颜色的图片。图片的任何透明度都将被忽略，这是默认的标志。
- `cv2.IMREAD_GRAYSCALE`：图片会以灰度格式被读入。
- `cv2.IMREAD_UNCHANGED`：按照图片本身的颜色设置读入，包含alpha通道。

如果你觉得这三个标志太长了，你可以简单地传入1、0或是-1。

看下面的代码：

```python
import numpy as np
import cv2
# 读一幅灰度格式的图像
img = cv2.imread('messi5.jpg',0)
```

**警告**

即使图片路径错误，`imread`函数也不会抛出任何错误，但是`print img`将会输出`None`。

### 显示一幅图片

使用函数`cv2.imshow()`来在一个窗口中显示一幅图片。窗口会自动适应图片的大小。

第一个参数是窗口的名字（字符串）。第二个参数是我们的图片。你可以创建任意数量的窗口，但必须要给他们不同的窗口名字。

```python
cv2.imshow('image',img)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

一个窗口的截屏应该会像这样（在Fedora-Gnome机器上）：

![image](images/opencv_screenshot.jpg)

`cv2.waitKey()`是一个键盘操作函数。它的参数是以毫秒为单位的时间值。这个函数在一段时间（指定的毫秒数）内等待键盘被按下，如果你在这段时间内按下了任何按键，程序将会继续执行。如果传入$0$，它将会一直等待一个键被按下。它也能用来拦截特定按键被按下的事件等等，我们会在下面说到这一点。

除了绑定键盘事件外这个函数还要处理很多其他GUI事件，所以你必须使用它来“真正地”显示出图片。

`cv2.destroyAllWindows()`简单地销毁你创建的所有窗口。如果你希望销毁特定的某一个窗口，你需要使用`cv2.destroyWindow()`，这个函数接受窗口的名字作为参数。

有一种特别的情况，就是你要先创建一个窗口然后再在稍后为其加载图片。在这种情况下，你可以声明这个窗口是否可以改变大小。这是通过函数`cv2.namedWindow()`来完成的。默认情况下，这个标志是`cv2.WINDOW_AUTOSIZE`。但你如果你使用`cv2.WINDOW_NORMAL`，你就可以手动改变窗口的大小。这对于尺寸太大的图片和创建滑块控制条很有帮助。

看下面的代码：

```python
cv2.namedWindow('image', cv2.WINDOW_NORMAL)
cv2.imshow('image',img)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

### 写入一幅图片

使用函数`cv2.imwrite()`来保存一幅图片。

第一个参数是文件名，第二个参数是你要保存的图片。

```python
cv2.imwrite('messigray.png',img)
```

者将会把png格式的图片保存到工作目录下。

### 把它们结合起来

下面的代码读取灰度格式的图片，显示它，如果你按下's'键，则保存并退出，如果你按下ESC键则只退出不保存。

```python
import numpy as np
import cv2

img = cv2.imread('messi5.jpg',0)
cv2.imshow('image',img)
k = cv2.waitKey(0)
if k == 27:         # 按下ESC键，直接退出
    cv2.destroyAllWindows()
elif k == ord('s'): # 按下's'键，保存并退出
    cv2.imwrite('messigray.png',img)
	cv2.destroyAllWindows()
```

**警告**

如果你在使用64位机，你需要把`k = cv2.waitKey(0)`改成：`k = cv2.waitKey(0) & 0xFF`

## 使用Matplotlib

Matplotlib是一个Python绘图库，它给予了你很多种不同的绘图方式。你将在下面的文章中看到它们。在这里，你会学到如何使用Matplotlib显示图片。你可以使用Matplotlib缩放图片、保存它等等。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt

img = cv2.imread('messi5.jpg',0)
plt.imshow(img, cmap = 'gray', interpolation = 'bicubic')
plt.xticks([]), plt.yticks([])  # 在x和y轴上隐藏刻度
plt.show()
```

结果看起来像这样：

![image](images/matplotlib_screenshot.jpg)

Matplotlib有很多绘图选项，欲知更多细节，请查询Matplotlib文档。我们在学习过程中也会接触其中一些。

**警告**

OpenCV读取的图片的颜色模式是BGR。但Matplotlib显示图片的颜色模式是RGB。因此有用OpenCV打开的有颜色的图片在Matplotlib中并不会正确地显示。请看练习部分来获取更多相关细节。

## 更多资源

- [Matplotlib绘图样式和特性](http://matplotlib.org/api/pyplot_api.html)

## 练习

- 当你试着用OpenCV读取有颜色的图片，然后用Matplotlib显示它的时候会出现问题，阅读[这个讨论](http://stackoverflow.com/a/15074748/1134940)来理解这个问题。

