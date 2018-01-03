# 特征匹配和使用单应性匹配来搜索物体{#tutorial_py_feature_homography_cn}

## 目标

在这一章中，

- 我们将混合特征匹配和来自`calib3d`的单应性匹配来从一个复杂的图像中寻找已知的物体。

## 基础

我们在上节课做了什么？我们使用了一个queryImage，在其中找到了一些特征点，我们又拿了一个trainImage，在那个图像中也找到了这些特征，并且找到了它们之间最好的匹配。

总之，我们在另一个混乱的图像中发现了一个物体某些部分的位置。这些信息足以在trainImage上准确找到对象。

为此，我们可以使用calib3d模块的函数`cv2.findHomography()`。如果我们传入这两个图像的点集，它会找到该对象的变换。然后我们可以使用`cv2.perspectiveTransform()`来查找对象。它需要至少四个正确的点来找到变换。

我们已经看到，可能会有一些可能的错误匹配来影响结果。为了解决这个问题，算法使用`RANSAC`或`LEAST_MEDIAN`（可以由标志决定）。提供正确估计的好匹配被称为inlier，其余被称为outlier。

`cv2.findHomography()`返回一个确定了inlier和outlier的掩码。

让我们来动手吧！

## 代码

首先，像往常一样，让我们找到图像中的SIFT特征，并应用比率测试来找到最佳匹配。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt
MIN_MATCH_COUNT = 10
img1 = cv2.imread('box.png',0)          # queryImage
img2 = cv2.imread('box_in_scene.png',0) # trainImage
# 初始化SIFT检测器
sift = cv2.xfeatures2d.SIFT_create()
# 用SIFT检测器搜索关键点和描述子
kp1, des1 = sift.detectAndCompute(img1,None)
kp2, des2 = sift.detectAndCompute(img2,None)
FLANN_INDEX_KDTREE = 1
index_params = dict(algorithm = FLANN_INDEX_KDTREE, trees = 5)
search_params = dict(checks = 50)
flann = cv2.FlannBasedMatcher(index_params, search_params)
matches = flann.knnMatch(des1,des2,k=2)
# 对所有好的匹配进行Lowe's比率测试
good = []
for m,n in matches:
	if m.distance < 0.7*n.distance:
    	good.append(m)
```

现在我们设置一个条件，至少有10个匹配（由`MIN_MATCH_COUNT`定义）才能确定找到了对象。 否则，只需显示一条消息，告诉用户不存在足够的匹配。

如果找到足够的匹配，我们提取两个图像中匹配关键点的位置。 寻找他们之间的变换关系。 一旦我们得到这个3x3转换矩阵，我们用它来将queryImage的角点转换成trainImage中相应的点。 然后我们绘制它。

```python
if len(good)>MIN_MATCH_COUNT:
	src_pts = np.float32([ kp1[m.queryIdx].pt for m in good ]).reshape(-1,1,2)
	dst_pts = np.float32([ kp2[m.trainIdx].pt for m in good ]).reshape(-1,1,2)

	M, mask = cv2.findHomography(src_pts, dst_pts, cv2.RANSAC,5.0)
	matchesMask = mask.ravel().tolist()

	h,w,d = img1.shape
	pts = np.float32([ [0,0],[0,h-1],[w-1,h-1],[w-1,0] ]).reshape(-1,1,2)
	dst = cv2.perspectiveTransform(pts,M)

	img2 = cv2.polylines(img2,[np.int32(dst)],True,255,3, cv2.LINE_AA)
else:
    print( "Not enough matches are found - {}/{}".format(len(good), MIN_MATCH_COUNT) )
matchesMask = None
```

最后，我们绘制我们的inlier（如果成功找到物体）或匹配关键点（如果没找到）。

```python
draw_params = dict(matchColor = (0,255,0), # 用绿色画出匹配点
					singlePointColor = None,
               		matchesMask = matchesMask, # 只画出inliers
               		flags = 2)
img3 = cv2.drawMatches(img1,kp1,img2,kp2,good,None,**draw_params)
plt.imshow(img3, 'gray'),plt.show()
```

看下面的结果。 对象在混乱的图像中以白色标记：

![image](images/homography_findobj.jpg)