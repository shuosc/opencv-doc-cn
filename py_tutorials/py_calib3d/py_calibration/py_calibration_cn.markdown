# 相机校准{#tutorial_py_calibration_cn}

## 目标

在这个部分，

- 我们将学习相机的扭曲，相机的内在和外在参数等。
- 我们将学习找到这些参数，让失真图像复原等

##基本知识

现代的的便宜针孔相机引起了很多图像失真。两个主要的失真是径向失真和切向失真。

由于径向扭曲，直线会出现弯曲。当我们离开图像的中心时，它的效果就更大了。例如，下面显示了一个图像，棋盘的两个边缘用红线标出。但是你可以看到边框不是一条直线，与红线不匹配。所有预期中的直线都凸出来了。访问[畸变](https://zh.wikipedia.org/wiki/畸變)了解更多详情。



这个失真表示如下：

$$
x_{distorted} = x( 1 + k_1 r^2 + k_2 r^4 + k_3 r^6) \\
y_{distorted} = y( 1 + k_1 r^2 + k_2 r^4 + k_3 r^6)\
$$



类似地，另一畸变是由于图像摄取镜头没有完全平行于成像平面对准而发生的切向畸变。因此，图像中的某些区域可能看起来比预期更近。它表示如下：

$$
x_{distorted} = x + [ 2p_1xy + p_2(r^2+2x^2)] \\
y_{distorted} = y + [ p_1(r^2+ 2y^2)+ 2p_2xy]
$$

总之，我们需要找到五个参数，称为失真系数，由下式给出：

$$
Distortion \; coefficients=(k_1 \hspace{10pt} k_2 \hspace{10pt} p_1 \hspace{10pt} p_2 \hspace{10pt} k_3)
$$

除此之外，我们还需要找到更多的信息，例如相机的内部和外部参数。内在参数是相机专用的。它包括焦距（$f_x,f_y$），光学中心（$c_x, c_y$）等信息，也被称为摄像机矩阵。它只取决于相机，所以一旦被计算了出来，它可以被存储以备将来之用。它被表示为一个3x3矩阵：

$$
camera \; matrix = \left [ \begin{matrix}   f_x & 0 & c_x \\  0 & f_y & c_y \\   0 & 0 & 1 \end{matrix} \right ]
$$

外部参数对应于将3D点的坐标转换为坐标系的旋转和平移向量。

对于立体应用，首先需要纠正这些失真。要找到所有这些参数，我们所要做的就是提供一些定义良好的图案的示例图像（例如国际象棋棋盘）。我们找到一些具体的点（在棋盘的方形的角上的点）。我们知道它在现实世界中的坐标，我们知道它在图像中的坐标。利用这些数据，可以在后台解决一些数学问题来解出失真系数。这是整个过程的大概。为了获得更好的结果，我们至少需要10组测试数据。

## 代码

如上所述，我们需要至少10个相机校准的测试数据组。 OpenCV附带一些国际象棋棋盘的图像（参见samples/cpp/left01.jpg - left14.jpg），所以我们会利用它。为了理解考虑，只考虑棋盘的一个图像。相机校准所需的重要输入数据是一组三维真实世界点及其相应的二维图像点。 2D图像点是可以从图像中轻松找到的。 （这些图像点是两个黑方块在棋盘上相互接触的位置）

那么从现实世界空间的3D点呢？这些图像是从静态相机拍摄的，棋盘放置在不同的位置和方向。所以我们需要知道(X,Y,Z)的值。但是为了简单起见，我们可以说棋盘在XY平面上保持静止，（所以总是有Z = 0），摄像机也随之移动。这个考虑有助于我们找到只有X，Y值。现在对于X，Y值，我们可以简单地通过点（0,0），（1,0），（2,0），...这表示点的位置。在这种情况下，我们得到的结果将会是棋盘格尺寸的大小。但是如果我们知道每个方块的尺寸（比如说30平方毫米），我们可以通过(0,0),(30,0),(60,0)...这样的值，我们得到的结果是毫米。 （在这种情况下，我们不知道方块的尺寸，因为这些图像不是我们拍摄的，所以我们传入以1格为一个单位的尺寸）。

3D点称为**对象点**，2D点称为**图像点**。

## 设置

所以要在棋盘上找到图案，我们使用函数`cv2.findChessboardCorners()`。我们还需要通过什么样的模式，如8x8网格，5x5网格等。在这个例子中，我们使用7x6网格。 （通常棋盘有8x8的方块和7x7的内部角点）。它返回角点和retval，如果得到找到了pattern，retval将是True。这些角落将按顺序排序（从左到右，从上到下）。

此功能可能无法在所有图像中找到所需的图案。所以一个好的选择是编写这样的代码，它启动相机，并检查每个帧的所需模式。一旦获得图案，找到角落并将其存储在列表中。在阅读下一帧之前还提供了一些时间间隔，以便我们可以在不同的方向调整我们的棋盘。继续这个过程，直到获得所需数量的好模式。即使在提供的示例中，我们也不确定在14张图片中，有多少是好的。所以我们读入所有的图像，并采取其中好的那些。

代替国际象棋棋盘，我们可以使用一些圆形网格，然后使用函数`cv2.findCirclesGrid()`来查找模式。据说使用圆形网格时所需的的图像数量较少。

一旦我们找到了角落，我们可以使用`cv2.cornerSubPix()`来提高它们的准确性。我们也可以使用`cv2.drawChessboardCorners()`来绘制模式。所有这些步骤都包含在下面的代码中：

```python
import numpy as np
import cv2
import glob

# 确定精度
criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

# 准备点的坐标 (0,0,0), (1,0,0), (2,0,0) ....,(6,5,0)
objp = np.zeros((6*7,3), np.float32)
objp[:,:2] = np.mgrid[0:7,0:6].T.reshape(-1,2)

# 对象点和图像点
objpoints = [] # 真实空间中的3d点
imgpoints = [] # 图像平面中的2d点

images = glob.glob('*.jpg')

for fname in images:
    img = cv2.imread(fname)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # 查找棋盘格点
    ret, corners = cv2.findChessboardCorners(gray, (7,6), None)
    
    # 如果找到了，将其优化并加入
    if ret == True:
        objpoints.append(objp)
    
        corners2=cv2.cornerSubPix(gray,corners, (11,11), (-1,-1), criteria)
        imgpoints.append(corners)
    
        # 绘制显示角点
        cv2.drawChessboardCorners(img, (7,6), corners2, ret)
        cv2.imshow('img', img)
        cv2.waitKey(500)

cv2.destroyAllWindows()
```

下面显示了一个有模式的图案：

![image](images/calib_pattern.jpg)

## 校准

所以现在我们有我们的目标点和图像点了，我们可以准备去校准相机了。为此我们使用函数`cv2.calibrateCamera()`。它返回相机矩阵，失真系数，旋转和平移向量等。

```python
ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(objpoints, imgpoints, gray.shape[::-1], None, None)
```

## 复原失真图像

我们已经得到了我们尝试要找到的东西。现在我们可以来复原一个扭曲过的图像。 OpenCV有两种方法，我们都将会看到。但在此之前，我们可以使用`cv2.getOptimalNewCameraMatrix()`根据一个自由缩放参数来细化相机矩阵。如果缩放参数$\alpha = 0$，则返回不失真的图像，其中不需要的像素最少。所以它甚至可能会删除图像角落的一些像素。如果$\alpha = 1$，所有像素都会保留，还会出现一些额外的黑色图像。它还会返回一个可用于裁剪结果的图像ROI。

所以我们拍一个新的图像（在这个例子中是left12.jpg，这是本章的第一个图像）

```python
img = cv2.imread('left12.jpg')
h,  w = img.shape[:2]
newcameramtx, roi=cv2.getOptimalNewCameraMatrix(mtx, dist, (w,h), 1, (w,h))
```

1. 使用`cv2.undistort()`

   这是最简单的方法。只需调用该函数并使用上面获得的ROI裁剪结果即可。

   ```python
   # undistort
   dst = cv2.undistort(img, mtx, dist, None, newcameramtx)

   # 裁剪图像
   x, y, w, h = roi
   dst = dst[y:y+h, x:x+w]
   cv2.imwrite('calibresult.png', dst)
   ```

2. 使用remapping

   这是比较曲折的方法。首先需要找到一个从扭曲过的图片转换到未扭曲的图片的对应关系（函数），接着要应用`remap`函数。

   ```python
   # undistort
   mapx, mapy = cv2.initUndistortRectifyMap(mtx, dist, None, newcameramtx, (w,h), 5)
   dst = cv2.remap(img, mapx, mapy, cv2.INTER_LINEAR)

   # 裁剪图像
   x, y, w, h = roi
   dst = dst[y:y+h, x:x+w]
   cv2.imwrite('calibresult.png', dst)
   ```


两种方法的结果是一样的，看下面的结果：

![image](images/calib_result.jpg)

你可以看到所有的边缘现在都是直的了。

## 反向投影误差

反向投影误差可以很好地估计出找到的参数的确切程度。这应尽可能接近于零。给定内在的，扭曲的，旋转和平移矩阵，我们首先使用`cv2.projectPoints()`将对象点转换成图像点。然后我们计算我们的变换和角点搜索算法之间的绝对规范。为了找到平均误差，我们计算所有校准图像的误差的算术平均值。

```python
mean_error = 0
for i in xrange(len(objpoints)):
    imgpoints2, _ = cv2.projectPoints(objpoints[i], rvecs[i], tvecs[i], mtx, dist)
    error = cv2.norm(imgpoints[i], imgpoints2, cv2.NORM_L2)/len(imgpoints2)
    mean_error += error

print( "total error: {}".format(mean_error/len(objpoints)) )
```

## 练习

- 尝试使用圆形网格进行摄像头校准。