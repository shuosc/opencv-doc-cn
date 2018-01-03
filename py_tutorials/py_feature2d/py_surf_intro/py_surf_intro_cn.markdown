# 介绍SURF（加速稳健特征）{#tutorial_py_surf_intro_cn}

## 目标

在这一章中，

- 我们将学习SURF的基础知识
- 我们将学习OpenCV中的SURF

## 理论基础

在上一章中，我们学习了SIFT的关键点检测和描述。 但是速度比较慢，人们需要更加快速的算法。 2006年，Bay, H. , Tuytelaars, T. 和 Van Gool, L,三人发表了另一篇名为《SURF: Speeded Up Robust Features》[^1]的论文，其中介绍了一种名为SURF的新算法。 顾名思义，这是SIFT的加速版本。

在SIFT中，Lowe 用高斯差分来近似拉普拉斯高斯算子来寻找尺度空间。 SURF走得更远一点，用盒式滤波器逼近LoG。 下图是这种近似的演示。 这种近似的一大优点是，利用积分图像可以容易地计算与盒式滤波器的卷积。 它可以在不同的尺度上并行完成。 SURF依赖于Hessian矩阵的行列式和位置的行列式。

![image](images/surf_boxfilter.jpg)

对于方向分配，SURF使用水平和垂直方向的小波响应来确定6s的邻域。 适当的高斯权值也适用于它。 然后将它们绘制在下图中给出的空间中。 通过计算在角度60度的滑窗内的所有响应的总和来估计主导方向。 有趣的是，可以很容易地在任何尺度上使用积分图像找出小波响应。 对于许多应用来说，旋转不变是不需要的，所以不需要找到这个方向，这就加快了这个过程。 SURF提供了称为Upright-SURF或U-SURF的功能。 它提高了速度，并且在$\pm 15^{\circ}$之中稳健的。 OpenCV两种都支持，取决于标志，`upright`。 如果是0，则计算方向。 如果是1，则不计算方向，速度更快。

![image](images/surf_orientation.jpg)



对于特征描述，SURF使用水平和垂直方向的小波响应（再一次地，我们使用积分图像使其更容易）。 大小为20s×20s的邻域是围绕s的大小的关键点。 它被分为4x4个分区域。 对于每个子区域，采取水平和垂直小波响应，并且形成像这样的矢量，

$$
v=(\sum {d_x}，\sum {d_y}，\sum {| d_x |}，\sum {| d_y |})
$$
这表示为一个向量，SURF特征描述符总共有64个维度。 维度越低，计算和匹配的速度越高，也能提供更好的特征的独特性。

为了更好的独特性，SURF特征描述符具有扩展的128维版本。
  $d_y <0$和$d_y\geq 0$对应的$d_x$和$|d_x|$的总和被分别计算出来。
类似地，$d_y$和$|d_y|$的总和也按照$d_x$的符号进行分割，从而使特征的数量加倍。 它不会增加太多的计算复杂性。 OpenCV支持通过设置标志`extended`的值分别为0和1，来分别表述使用64-dim和128-dim的SURF描述符（默认为128-dim）。

另一个重要的改进是使用拉普拉斯符号（Hessian矩阵的转置）作为潜在兴趣点。 它不会增加计算成本，因为它在检测期间已经被计算。 拉普拉斯的标志在黑暗的背景下将明亮的斑点与相反的情况区分开来。 在匹配阶段，我们只比较具有相同类型对比度的特征（如下图所示）。 这个最小的信息允许更快的匹配，而不降低描述符的性能。

![image](images/surf_matching.jpg)

总之，SURF增加了很多功能来提高每一步的速度。 分析显示，它比SIFT快3倍，而性能与SIFT相当。 SURF擅长处理模糊和旋转的图像，但不擅长处理视点变化和光照变化。

## OpenCV中的SURF

OpenCV的SURF功能就像SIFT一样。你用一些可选的条件来初始化一个SURF对象，比如64/128-dim描述符，Upright/Normal SURF等等。所有的细节在文档中都有很好的解释。 然后就像我们在SIFT中所做的那样，我们可以使用`SURF.detect()`，`SURF.compute()`等来查找关键点和描述符。

首先，我们将看到一个关于如何找到SURF关键点和描述符并绘制的简单演示。 

```python
img = cv2.imread('fly.png',0)
# 创建一个SURF对象。你可以就在这里写明参数或者等以后再写
# 这里我们设置Hessian阈值为400
surf = cv2.xfeatures2d.SURF_create(400)
# 直接寻找关键点和描述符
kp, des = surf.detectAndCompute(img,None)
len(kp) # 699
```

在图片中显示1199个关键点显得有些太多了。我们把这一数字减小到50。

```python
# 检测现有的Hessian阈值
print(surf.getHessianThreshold()) # 400.0
# 我们将其设置为50000
# 这仅仅是为了显示方便
# 在实际使用中，这个值最好是300-500中的一个值
surf.setHessianThreshold(50000)
# 重新计算关键点和描述符
kp, des = surf.detectAndCompute(img,None)
print(len(kp)) # 47
```

小于50个，我们可以在图上把它画出来了。

```python
img2 = cv2.drawKeypoints(img,kp,None,(255,0,0),4)
plt.imshow(img2)
plt.show()
```

看下面的结果，你可以看出SURF更像一个斑点检测器。它检测出了蝴蝶翅膀上的白色斑点。你可以在其他图片上尝试一下。

![image](images/surf_kp1.jpg)

现在我们想要使用U-SURF，这样找到的特征就不会包含方向信息了。

```python
# 检查upright标志，如果它是False，置为True
print(surf.getUpright()) # False
surf.setUpright(True)
# 重新计算关键点和描述符，并绘制图像
kp = surf.detect(img,None)
img2 = cv2.drawKeypoints(img,kp,None,(255,0,0),4)
plt.imshow(img2)
plt.show()
```

看看下面的结果。所有的方向都指向了同一方向。这样做大大加快了速度。如果对于你现在在做的事来说方向不那么重要（全景拼接等），这么做更好。

![image](images/surf_kp2.jpg)

最后，我们检测描述符的大小，如果是64-dim的，就将其更改为182-dim。

```python
# 检测描述符大小
print(surf.descriptorSize()) # 64
# 这意味着“extended”标志是False
surf.getExtended() # False
# 我们将其置为True来获得128-dim的描述符。
surf.extended = True
kp, des = surf.detectAndCompute(img,None)
print(surf.descriptorSize()) # 128
print(des.shape) # (47, 128)
```

接下来要做的事就是匹配特征点了，我们将在另外一章中讲述相关内容。

[^1]: http://www.vision.ee.ethz.ch/~surf/eccv06.pdf 

