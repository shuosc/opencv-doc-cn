# 姿势估计{#tutorial_py_pose_cn}

## 目标

在这个部分，

- 我们将学习利用calib3d模块在图像中创建一些3D效果。

##基础知识

这将是一个小的章节。在上一次相机校准的过程中，您已经找到相机矩阵，失真系数等等。给定一个模式图像，我们可以利用上面的信息来计算它的姿态，或者物体在空间中的位置如何旋转，它是如何移动的等等。对于一个平面物体，我们可以假设Z = 0，这样现在问题就变成了如何将相机放置在空间中来观看我们的图案图像。所以，如果我们知道物体在空间中的位置，我们可以画出一些二维图像来模拟三维效果。让我们看看如何做到这一点。

我们的问题是，我们想在我们的棋盘的第一个角上绘制我们的3D坐标轴（x,y,z轴）。 X轴为蓝色，Y轴为绿色，Z轴为红色。Z轴应该感觉像是垂直于我们的棋盘平面。

首先，我们从上一次的校准结果中加载相机矩阵和失真系数。

```python
import cv2
import numpy as np
import glob

# Load previously saved data
with np.load('B.npz') as X:
    mtx, dist, _, _ = [X[i] for i in ('mtx','dist','rvecs','tvecs')]
```

现在我们来创建一个函数，绘制棋盘上的角点（使用`cv2.findChessboardCorners()`获取）和轴点来绘制3D轴。

```python
def draw(img, corners, imgpts):
    corner = tuple(corners[0].ravel())
    img = cv2.line(img, corner, tuple(imgpts[0].ravel()), (255,0,0), 5)
    img = cv2.line(img, corner, tuple(imgpts[1].ravel()), (0,255,0), 5)
    img = cv2.line(img, corner, tuple(imgpts[2].ravel()), (0,0,255), 5)
    return img
```

然后和前面一样，我们创建终止精度，目标点（棋盘上的三角点）和轴点。轴点是绘制轴的三维空间中的点。我们绘制长度为3的轴（单位以是棋盘方块的大小定的，因为这是我们校准时使用的大小单位）。所以我们的X轴是从(0,0,0)到(3,0,0)，对Y轴也是这样。对于Z轴，它从(0,0,0)到(0,0,-3)绘制。负值表示它朝向相机。

```python
criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)
objp = np.zeros((6*7,3), np.float32)
objp[:,:2] = np.mgrid[0:7,0:6].T.reshape(-1,2)

axis = np.float32([[3,0,0], [0,3,0], [0,0,-3]]).reshape(-1,3)
```

现在像往常一样，我们加载每个图像。搜索7x6网格。如果找到，我们使用小角点像素进行细化。然后为了计算旋转和平移，我们使用函数`cv2.solvePnPRansac()`。一旦我们找到了这些变换矩阵，我们使用它们将我们的轴点投影到图像平面。简单地说，我们在三维空间中找到对应于(3,0,0)，(0,3,0)，(0,0,3)中的每一个的图像平面上的点。一旦我们得到它们，我们使用`draw()`函数从第一个角点到这每一个点画一条线。完成！

```python
for fname in glob.glob('left*.jpg'):
    img = cv2.imread(fname)
    gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
    ret, corners = cv2.findChessboardCorners(gray, (7,6),None)
    
    if ret == True:
        corners2 = cv2.cornerSubPix(gray,corners,(11,11),(-1,-1),criteria)
    
        # 寻找旋转和变换向量
        ret,rvecs, tvecs, inliers = cv2.solvePnP(objp, corners2, mtx, dist)
    
        # 将3D点投影到图像平面上
        imgpts, jac = cv2.projectPoints(axis, rvecs, tvecs, mtx, dist)
    
        img = draw(img,corners2,imgpts)
        cv2.imshow('img',img)
        k = cv2.waitKey(0) & 0xFF
        if k == ord('s'):
            cv2.imwrite(fname[:6]+'.png', img)

cv2.destroyAllWindows()
```



看下面的一些结果。请注意，每个轴的长度是3个方块。

![image](images/pose_1.jpg)

###  渲染一个立方体

如果要绘制立方体，请按如下所示修改`draw()`函数和轴点。

修改`draw()`函数：

```python
def draw(img, corners, imgpts):
    imgpts = np.int32(imgpts).reshape(-1,2)

    # draw ground floor in green
    img = cv2.drawContours(img, [imgpts[:4]],-1,(0,255,0),-3)
    
    # draw pillars in blue color
    for i,j in zip(range(4),range(4,8)):
        img = cv2.line(img, tuple(imgpts[i]), tuple(imgpts[j]),(255),3)
    
    # draw top layer in red color
    img = cv2.drawContours(img, [imgpts[4:]],-1,(0,0,255),3)
    
    return img
```
修改轴点。它们是3D空间中立方体的8个角：

```python
axis = np.float32([[0,0,0], [0,3,0], [3,3,0], [3,0,0],
                   [0,0,-3],[0,3,-3],[3,3,-3],[3,0,-3] ])
```
看看下面的结果：

![image](images/pose_2.jpg)

如果你对图形，增强现实等感兴趣，你可以使用OpenGL渲染更复杂的图形。