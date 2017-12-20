# 图像算术操作{#tutorial_py_image_arithmetics_cn}

## 目标

- 学习几个图像算术操作，例如加、减、位操作等等。
- 你会学到这些函数：`cv2.add()`、`cv2.addWeighted()`等等。

## 图片相加

你可以通过OpenCV函数`cv2.add()`将两个图像相加，或者简单地通过Numpy操作符`res = img1 + img2`将两个图像相加。这两个图像应该有相同的深度和类型，或者第二个“图像”也可以只是一个标量值。

OpenCV加法和Numpy加法是有区别的。在结果超出数据范围时OpenCV加法执行一个饱和操作（即将结果限制到一定范围内），而Numpy加法执行一个模操作（即将结果对某个数取模）。

例如，请考虑下面的示例：

```python
>>> x = np.uint8([250])
>>> y = np.uint8([10])

>>> print( cv2.add(x,y) ) # 250 + 10 = 260 => 255
>>> [[255]]

>>> print( x+y )          # 250 + 10 = 260 % 256 = 4
>>> [4]
```

当你将两个图像相加时，区别会更加明显。 OpenCV函数将提供更好的结果。所以最好总是坚持使用OpenCV函数。

## 图像混合

这其实也是图像相加的一种，但所不同的是会对图像赋予不同的权重，以便体现出混合或透明的感觉。图像按照以下公式相加：
$$
g(x)=(1-\alpha)f_{0}(x)+ \alpha f_{1}(x)
$$


通过将$\alpha$从$0 \rightarrow 1$，你可以在两个图像之间执行一个很酷的转换。

在这里，我把两个图像混合在一起。第一个图像的权重为0.7，第二个图像的权重为0.3。` cv2.addWeighted()`在图像上应用以下公式。
$$
dst = \alpha \cdot img1 + \beta \cdot img2 + \gamma
$$


在这里$\gamma$被视为零。

```python
img1 = cv2.imread('ml.png')
img2 = cv2.imread('opencv-logo.png')

dst = cv2.addWeighted(img1,0.7,img2,0.3,0)

cv2.imshow('dst',dst)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

下面是运行结果：

![image](images/blending.jpg)

## 位操作

包括按位AND，OR，NOT和XOR操作。在提取图像的某个部分（正如我们将在后面的章节中看到的那样）或定义和处理非矩形的ROI等等的时候，它们将非常有用。下面我们将看到一个关于如何更改图像的特定区域的示例。

我想把OpenCV标志放在图片的上方。如果我直接将两个图像相加，它会改变颜色。如果我把它混合，我会得到一个半透明的效果。但我希望它是不透明的。如果这是一个矩形区域，我可以像上一章那样使用ROI。但OpenCV标志不是矩形的。所以你需要通过位操作来完成，如下所示：

```python
# 读入两张图片
img1 = cv2.imread('messi5.jpg')
img2 = cv2.imread('opencv-logo.png')
# 我想把图片放在左上角，所以我创建了一个ROI
rows,cols,channels = img2.shape
roi = img1[0:rows, 0:cols]
# 现在创建一个标志的mask，同时也创建其反mask
img2gray = cv2.cvtColor(img2,cv2.COLOR_BGR2GRAY)
ret, mask = cv2.threshold(img2gray, 10, 255, cv2.THRESH_BINARY)
mask_inv = cv2.bitwise_not(mask)
# 将ROI中的logo区域变黑
img1_bg = cv2.bitwise_and(roi,roi,mask = mask_inv)
# 从logo的图片中获取logo
img2_fg = cv2.bitwise_and(img2,img2,mask = mask)
# 将logo放入ROI并修改原来的图片
dst = cv2.add(img1bg,img2fg)
img1[0:rows, 0:cols ] = dst
cv2.imshow('res',img1)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

下面是结果。左图显示了我们创建的mask。右图显示了最终结果。为了更好理解，在上面的代码显示了所有的中间图片，也就是`img1_bg`和`img2_fg`。

![image](images/overlay.jpg)

## 练习

- 使用`cv2.addWeighted()`函数，创建文件夹中图像的平滑过渡的幻灯片放映。

