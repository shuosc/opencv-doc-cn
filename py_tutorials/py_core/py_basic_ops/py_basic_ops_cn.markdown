# 图片基本操作{#tutorial_py_basic_ops_cn}

## 目标

学会：

- 获取像素的值并更改它们
- 获取图像属性
- 设置感兴趣的区域（Region of Interest，ROI）
- 分割和合并图像

几乎所有这些操作都和Numpy相关而和OpenCV没什么关系。精通Numpy对于写更好地优化的OpenCV代码是必要的。

*（例子将使用Python控制台，因为它们中大多数都只是一行代码）*

## 获取和更改像素的值

让我们先读取一个彩色图片：

```python
>>> import cv2
>>> import numpy as np
>>> img = cv2.imread('messi5.jpg')
```

你可以使用一个像素的纵横坐标获取一个像素。对于BGR格式的图片，它会返回一个由蓝色、绿色和红色值组成的数组。对于灰度图片，只会返回对应的亮度。

```python
>>> px = img[100,100]
>>> print(px) # [157 166 200]
# 只获取蓝色的像素
>>> blue = img[100,100,0]
>>> print( blue ) # 157
```

你可以用同样的方式修改像素的值。

```python
>>> img[100,100] = [255,255,255]
>>> print(img[100,100]) # [255 255 255]
```

**警告**

Numpy是一个针对数组计算高度优化过的库。所以简单地获取每个像素的值并修改它是很慢的，我们不推荐这样做。

上面提到的方法常常用来选择数组的一个区域，比如说前5行或者最后三列这样的。对于单个像素，Numpy数组方法`array.item()`和`array.itemset()`更合适些。但这两个函数总是返回一个标量。所以如果你想要获取所有B、G、R的值，你需要对每种颜色分别调用`array.item()`。

更好地像素获取和编辑方法：

```python
# 获取红色的值
>>> img.item(10,10,2) # 59

# 修改红色的值
>>> img.itemset((10,10,2),100)
>>> img.item(10,10,2) #100
```

## 获取图片信息

图片信息包含行数、列数、通道数、图像数据类型、像素数量等等。

图片的形状使用`img.shape`获取。它返回一个包含行数、列数和通道数（如果图片是彩色的）的元组。

```python
>>> print( img.shape ) # (342, 548, 3)
```

如果图片是灰度图像，这个元组只会包含行数和列数。所以这是个检查图片是彩色图还是灰度图的好方法。

可以通过`img.size`查询像素总数：

```python
>>> print( img.size ) # 562248
```
图片数据的类型是用 `img.dtype`表示的:

```python
>>> print( img.dtype ) # uint8
```

注意`img.dtype`在调试程序中是很重要的，因为很多OpenCV-Python代码中的问题都是不合法的数据类型造成的。

## 图片的ROI

有时候，你会希望只关注图片的某一个部分。例如对于在图片中检测眼睛，首先先进行面部检测，当发现面部时，我们会选择面部区域，然后只在这个区域里检测眼睛，而非搜索整个图片。这能提高我们程序的准确率（因为眼睛总长在脸上:D ）和运行效率（因为我们寻找的区域减小了）。

ROI也是用Numpy索引来表示的。这里我们选择这幅图里的球并将它复制到图片的另外一个区域里：

```python
>>> ball = img[280:340, 330:390]
>>> img[273:333, 100:160] = ball
```

下面是运行结果：

![image](images/roi.jpg)

## 分割和合并图片的通道

有时候你需要分割开图片的B、G、R通道来完成工作。这时候你就需要将BGR颜色的图片分成不同的层。另一些时候，你需要把独立的通道合并成BGR的图片，你可以简单地这样做：

```python
>>> b,g,r = cv2.split(img)
>>> img = cv2.merge((b,g,r))
```

或者

```python
>>> b = img[:,:,0]
```

假如你要把所有像素的红色值设置为0，你不需要将它分离开来然后再将其置为0，你只需要简单地使用Numpy索引，这样做更快。

```python
>>> img[:,:,2] = 0
```

**警告**

`cv2.split()`会花费很多时间。所以只在你真的需要的时候再使用它。否则就使用Numpy索引。

## 给图片加边框（padding）

如果你想要给图片加一个边框，像相框那样，你可以使用`cv2.copyMakeBorder()`函数。他也有其他应用，像更为复杂的操作、不padding等等。这个函数接受下面的参数：

- `src` - 输入图片
- `top`、`button`、`left`、`right` - 相应方向上的边框宽度
- `borderType` - 决定边框类型的标准，可以取下面这些值：
  - `cv2.BORDER_CONSTANT` - 加一个单色边框，边框颜色需要在下一个参数中给出
  - `cv2.BORDER_REFLECT` - 边缘将会是边缘元素的镜像，像这样：*fedcba|abcdefgh|hgfedcb*
  - `cv2.BORDER_REFLECT_101`或`cv2.BORDER_REFLECT_101` - 和上面的只有一个细微的改变，像这样：*gfedcb|abcdefgh|gfedcba*
  - `cv2.BORDER_REPLICATE` - 最后一个元素被不断地重复，像这样：*aaaaaa|abcdefgh|hhhhhhh*
  - `cv2.BORDER_WRAP` - 不可描述，像这样：*cdefgh|abcdefgh|abcdefg*
- `value` - `cv2.BORDER_CONSTANT`所需要的的颜色值

下面是为了更好地理解而创建的代码示例：

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt
BLUE = [255,0,0]
img1 = cv2.imread('opencv-logo.png')
replicate = cv2.copyMakeBorder(img1,10,10,10,10,cv2.BORDER_REPLICATE)
reflect = cv2.copyMakeBorder(img1,10,10,10,10,cv2.BORDER_REFLECT)
reflect101 = cv2.copyMakeBorder(img1,10,10,10,10,cv2.BORDER_REFLECT_101)
wrap = cv2.copyMakeBorder(img1,10,10,10,10,cv2.BORDER_WRAP)
constant= cv2.copyMakeBorder(img1,10,10,10,10,cv2.BORDER_CONSTANT,value=BLUE)
plt.subplot(231),plt.imshow(img1,'gray'),plt.title('ORIGINAL')
plt.subplot(232),plt.imshow(replicate,'gray'),plt.title('REPLICATE')
plt.subplot(233),plt.imshow(reflect,'gray'),plt.title('REFLECT')
plt.subplot(234),plt.imshow(reflect101,'gray'),plt.title('REFLECT_101')
plt.subplot(235),plt.imshow(wrap,'gray'),plt.title('WRAP')
plt.subplot(236),plt.imshow(constant,'gray'),plt.title('CONSTANT')
plt.show()
```

结果如下（由于使用Matplotlib显示图像，红色和蓝色被交换了）。