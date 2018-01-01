# 图像金字塔{#tutorial_py_pyramids_cn}

## 目标

在这一章当中，

- 我们将学习图像金字塔
- 我们将使用图像金字塔来创建一个新的水果，“Orapple” <!--😂-->
- 我们将学到这些函数：`cv2.pyrUp()`，`cv2.pyrDown()`


## 理论基础

通常，我们习惯使用一个大小不变的图像。但在某些时候，我们需要处理不同分辨率的同一图像。例如，当在图像中搜索某物时，我们不确定图像中物体的大小。在这种情况下，我们需要创建一组不同分辨率的图像，并在所有图像中搜索对象。这些具有不同分辨率的图像被合称为图像金字塔（因为它们中的最大图像被保存在最底层，最小图像被保存在最顶层，看起来像金字塔）。

有两种图像金字塔。 1）高斯金字塔和 2）拉普拉斯金字塔。

高斯金字塔中的较高层（低分辨率）是通过去除较低层（较高分辨率）图像中的连续行和列而形成的。然后，高层中的每个像素由高斯权重下的5个像素构成。通过这样做，$M \times N$大小的图像变成了$\frac M 2 \times \frac N 2$大小的图像。所以面积减少到原来面积的四分之一。这被称为Octave。随着我们走上金字塔（即分辨率下降），同样的模式将继续下去。同样在分辨率上升的时候，每个区域变成4倍。我们可以使用`cv2.pyrDown()`和`cv2.pyrUp()`函数查找到高斯金字塔中的每一层。

```python
img = cv2.imread('messi5.jpg')
lower_reso = cv2.pyrDown(higher_reso)
```

下面是金字塔中的四层：

![image](images/messipyr.jpg)

现在，您可以使用`cv2.pyrUp()`函数在图像金字塔中向下走。

```python
higher_reso2 = cv2.pyrUp(lower_reso)
```

请记住，`higher_reso2`不等于`higher_reso`，因为一旦降低了分辨率，就会丢失信息。下面的图像是从金字塔中最小的图像创建的金字塔的第3级。将其与原始图像进行比较：

![image](images/messiup.jpg)

拉普拉斯金字塔由高斯金字塔形成。没有专用的函数来构造拉普拉斯金字塔。拉普拉斯金字塔图像看起来像是边缘图像。其大部分元素是零。它们用于图像压缩。拉普拉斯金字塔的等级由高斯金字塔等级与高斯金字塔等级的高等级之间的差异形成。拉普拉斯金字塔的第3级如下（对比度被调整以增强内容）：

![image](images/lap.jpg)

## 使用金字塔进行图像混合

金字塔的一个应用是图像混合。例如，在图像拼接中，您需要将两个图像叠加在一起，但由于图像之间的不连续性，这可能看起来不太好。在这种情况下，使用金字塔图像进行混合可以实现无缝混合，而不会在图像中留下太多数据。其中一个典型的例子是两种水果橙子和苹果的混合。现在看看结果来明白我在说什么：

![image](images/orapple.jpg)

请查看附加资源中的第一个参考资料，它有关于图像混合，拉普拉斯金字塔等的完整详细的图解信息。简单来说只需完成以下步骤：

1. 加载苹果和橙子的两个图像
2. 找到苹果和橙子的高斯金字塔（在这个特定的例子中，层数是6）
3. 从高斯金字塔找到他们的拉普拉斯金字塔
4. 现在加入拉普拉斯金字塔各层苹果的左半部分和橙子的右半部分
5. 最后从这个联合图像金字塔重建原始图像。

以下是完整的代码。 （为了简单起见，每个步骤都是单独完成的，这可能需要更多内存。如果你愿意，你可以优化它）。

```python
import cv2
import numpy as np,sys

A = cv2.imread('apple.jpg')
B = cv2.imread('orange.jpg')

# 为A生成高斯金字塔
G = A.copy()
gpA = [G]
for i in xrange(6):
    G = cv2.pyrDown(G)
    gpA.append(G)

# 为B生成高斯金字塔
G = B.copy()
gpB = [G]
for i in xrange(6):
    G = cv2.pyrDown(G)
    gpB.append(G)

# 为A生成拉普拉斯金字塔
lpA = [gpA[5]]
for i in xrange(5,0,-1):
    GE = cv2.pyrUp(gpA[i])
    L = cv2.subtract(gpA[i-1],GE)
    lpA.append(L)
    
# 为B生成拉普拉斯金字塔
lpB = [gpB[5]]
for i in xrange(5,0,-1):
    GE = cv2.pyrUp(gpB[i])
    L = cv2.subtract(gpB[i-1],GE)
    lpB.append(L)

# 现在把每一层图像的左半边和右半边拼合起来
LS = []
for la,lb in zip(lpA,lpB):
    rows,cols,dpt = la.shape
    ls = np.hstack((la[:,0:cols/2], lb[:,cols/2:]))
    LS.append(ls)

# 重建图像
ls_ = LS[0]
for i in xrange(1,6):
    ls_ = cv2.pyrUp(ls_)
    ls_ = cv2.add(ls_, LS[i])

# 直接拼接的图像
real = np.hstack((A[:,:cols/2],B[:,cols/2:]))

cv2.imwrite('Pyramid_blending2.jpg',ls_)
cv2.imwrite('Direct_blending.jpg',real)
```

## 更多资源

- [图像混合](http://pages.cs.wisc.edu/~csverma/CS766_09/ImageMosaic/imagemosaic.html)