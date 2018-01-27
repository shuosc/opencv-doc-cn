# 极线几何{#tutorial_py_epipolar_geometry_cn}

## 目标

在这一章中，

- 我们将学习多视图几何的基础知识。
- 我们将看到什么是极点，极线，极线约束等。

## 基本概念

当我们使用针孔相机拍摄图像时，我们会丢失一个重要的信息，即图像的深度。或者从相机的图像中的每个点有多远，因为它是3D到2D的转换。所以使用这些摄像头是否能找到深度信息是一个重要的问题。一个解决方案是使用多个相机。我们的眼睛以类似的方式使用两个相机（两只眼睛），这就是所谓的立体视觉。那么让我们来看看OpenCV在这个领域提供了什么。

（Gary Bradsky的《Learning OpenCV》在这方面有很多信息。）

在研究深度图像之前，我们先来了解多视图几何中的一些基本概念。在本节中，我们将处理极线几何。请参阅下面的图像，其中显示了使用两台相机拍摄相同场景的基本设置。

![image](images/epipolar.jpg)

如果我们只使用左边的摄像机，我们无法找到与图像中的点$x$相对应的3D点，因为线$OX$上的每个点都投影到图像平面上的相同点。但是也要考虑右边的摄像机得到的图像。现在$O$X线上的不同点投射到右侧的不同点（$x'$）。所以对于这两幅图像，我们可以对正确的三维点进行三角测量。这就是整个想法。

$OX$上不同点的投影在右平面上形成一条线（$l'$）。我们称之为对应于点$x$的**极线**。这意味着，要找到右侧图像上的点$x$，只需沿着这个极线搜索。它应该在这一条线上的某个地方（这样的话，要找到其他图像中的匹配点，不需要搜索整个图像，只需沿着极线搜索，因此提供了更好的性能和准确性）。这被称为**极线约束**（Epipolar Constraint）。同样，所有的点在其他图像中都会有相应的极线。平面$XOO'$被称为对极平面（Epipolar Plane）。

$O$和$O'$是相机中心。从上面给出的设置中，可以看到右侧相机$O'$的投影在左侧图像上的点e处出现。它被称为**极点**。 极点是通过相机中心和图像平面的交叉点。类似地，$e'$是左侧相机的圆心。在某些情况下，您将无法找到图像中的圆点，它们可能在图像之外（也就是说，一个相机看不到另一个）。

所有的极线都穿过它的极点。所以要找到极点的位置，我们可以找到许多极线并找到它们的交点。

所以在这一章中，我们专注于寻找极线和极点。但要找到它们，我们还需要两个东西：**Fundamental矩阵(F)**和**Essential矩阵(E)**。Essential矩阵包含有关平移和旋转的信息，这些信息描述了第二个摄像机相对于全局坐标中第一个摄像机的位置。见下图（图片提供：Gary Bradsky 《Learning OpenCV》）：

![image](images/essential_matrix.jpg)

但我们更喜欢在像素坐标系中进行测量，对吧？Fundamental矩阵包含与Essential矩阵相同的信息，另外再加上两个相机的内在信息，以便我们可以将两个相机的像素坐标关联起来。 （如果我们正在使用矫正过的图像，并通过除以焦距来归一化该点，$F = E$）。简而言之，Fundamental矩阵F将一个图像中的一个点映射到另一个图像中的一条线（极线）。这是从两个图像的匹配点计算出来的。找到基本矩阵（使用8点算法时）至少需要8个这样的点。有更多的点就更好了，可以使用RANSAC得到一个健壮性更好的结果。

## 代码

所以首先我们需要找到两个图像之间尽可能多的匹配点来找到Fundamental矩阵。

为此，我们使用基于FLANN的匹配器和SIFT描述符，并进行比率测试。

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img1 = cv2.imread('myleft.jpg',0)  #queryimage # 左侧图片
img2 = cv2.imread('myright.jpg',0) #trainimage # 右侧图片

sift = cv2.SIFT()

# 用SIFT查找关键点和描述子
kp1, des1 = sift.detectAndCompute(img1,None)
kp2, des2 = sift.detectAndCompute(img2,None)

# FLANN参数
FLANN_INDEX_KDTREE = 1
index_params = dict(algorithm = FLANN_INDEX_KDTREE, trees = 5)
search_params = dict(checks=50)

flann = cv2.FlannBasedMatcher(index_params,search_params)
matches = flann.knnMatch(des1,des2,k=2)

good = []
pts1 = []
pts2 = []

# 按照Lowe的论文进行比率测试
for i,(m,n) in enumerate(matches):
    if m.distance < 0.8*n.distance:
        good.append(m)
        pts2.append(kp2[m.trainIdx].pt)
        pts1.append(kp1[m.queryIdx].pt)
```

现在我们有两张图片的最佳匹配点的列表。让我们找到Fundamental矩阵。

```python
pts1 = np.int32(pts1)
pts2 = np.int32(pts2)
F, mask = cv2.findFundamentalMat(pts1,pts2,cv2.FM_LMEDS)

# 我们只使用inlier点
pts1 = pts1[mask.ravel()==1]
pts2 = pts2[mask.ravel()==1]
```
接下来我们要找到极线。 第一图像中的点对应的极线的线条会在第二图像上绘制。 所以使用正确的图像在这里很重要。 我们得到一系列的线。 所以我们定义一个新的函数来在图像上绘制这些线条。
```python
def drawlines(img1,img2,lines,pts1,pts2):
    ''' img1 - 我们要绘制到的图像
        lines - 相应的极线 '''
    r,c = img1.shape
    img1 = cv2.cvtColor(img1,cv2.COLOR_GRAY2BGR)
    img2 = cv2.cvtColor(img2,cv2.COLOR_GRAY2BGR)
    for r,pt1,pt2 in zip(lines,pts1,pts2):
        color = tuple(np.random.randint(0,255,3).tolist())
        x0,y0 = map(int, [0, -r[2]/r[1] ])
        x1,y1 = map(int, [c, -(r[2]+r[0]*c)/r[1] ])
        img1 = cv2.line(img1, (x0,y0), (x1,y1), color,1)
        img1 = cv2.circle(img1,tuple(pt1),5,color,-1)
        img2 = cv2.circle(img2,tuple(pt2),5,color,-1)
    return img1,img2
```

现在我们在这两个图像中找到这些极线，并画出它们。

```python
# 找到右边图像（第二张图像）中的点对应的极线
# 在左边图像上画出来
lines1 = cv2.computeCorrespondEpilines(pts2.reshape(-1,1,2), 2,F)
lines1 = lines1.reshape(-1,3)
img5,img6 = drawlines(img1,img2,lines1,pts1,pts2)

# 找到左边图像（第一张图像）中的点对应的极线
# 在右边图像上画出来
lines2 = cv2.computeCorrespondEpilines(pts1.reshape(-1,1,2), 1,F)
lines2 = lines2.reshape(-1,3)
img3,img4 = drawlines(img2,img1,lines2,pts2,pts1)

plt.subplot(121),plt.imshow(img5)
plt.subplot(122),plt.imshow(img3)
plt.show()
```

下面是我们得到的结果：

![image](images/epiresult.jpg)

你可以从左边的图片中看到，所有的极线正在会聚在图像右侧的一个点上。 那个交汇点就是极点。

为了获得更好的结果，应该使用具有良好分辨率和许多不共面的点的图像。

## 练习

- 一个重要的话题是相机的向前移动。 然后在相同的位置看到极点，两个极线从一个固定点出现。 [见本讨论](http://answers.opencv.org/question/17912/location-of-epipole/)。
- Fundamental矩阵估计对匹配质量，离群值等非常敏感。当所有选择的匹配位于同一个平面上时，它变得更糟。 [看看这个讨论](http://answers.opencv.org/question/18125/epilines-not-correct/)。