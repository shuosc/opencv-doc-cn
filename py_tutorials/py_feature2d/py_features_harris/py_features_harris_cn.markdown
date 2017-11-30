# Harris角点检测{#tutorial_py_features_harris_cn}

## 目标

在这一章中，

- 我们将会理解Harris角点检测背后的概念
- 我们会了解`cv2.cornerHarris()`和`cv2.cornerSubPix()`函数的使用方法

## 理论基础

上一章中，我们已经看到边角是在图像中各个方向上亮度都变化非常大的区域。试图找到这些边角的一个早期尝试由Chris Harris 和 Mike Stephens在它们1988年的的论文《A Combined Corner and Edge Detector》[^1]中提出，所以这个方法现在就叫“Harris角点检测”。他把这个简单的想法变成了数学形式。它基本上找到了在所有方向上$f(u,v)$位移的亮度差异。这个方法由下面的的式子表述：
$$
E(u,v) = \sum_{x,y} \underbrace{w(x,y)}_{window\ function} \, [\underbrace{I(x+u,y+v)}_{shifted\ intensity}-\underbrace{I(x,y)}_{intensity}]^2
$$
窗口函数是一个矩形窗口或高斯窗口，它给其中的像素一个权重。

我们必须最大化这个函数$E(u,v)$来进行角点检测。 这意味着，我们必须取第二项的最大值。 将泰勒展开应用到上面的方程式上，并使用一些数学方法（请参考你喜欢的任何标准教科书以获得全面的推导），我们得到最终方程式为：
$$
E(u,v) \approx 
\begin{bmatrix} u & v \end{bmatrix} M \begin{bmatrix} u \\ v \end{bmatrix} \\
where  \\
M = \sum_{x,y} w(x,y) \begin{bmatrix}I_x I_x & I_x I_y \\ I_x I_y & I_y I_y \end{bmatrix}
$$
这里$I_x$和$I_y$是图像在$x$和$y$方向上的导数。（这可以使用`cv2.Sobel()`容易地求出。）

然后就是最主要的部分。 在上面这些步骤之后，他们创造了一个分数，基本上是一个方程式，它将决定一个窗口是否包含了一个边角。
$$
R = det(M) - k(trace(M))^2 \\
where
$$

- $det(M) = \lambda_1 \lambda_2$
- $trace(M) = \lambda_1 + \lambda_2$
- $\lambda_1$ 和 $\lambda_2$ 是$M$的特征值

从这些特征值的值就能看出一个区域是边角，边缘还是平坦的。

- 当$|R|$很小，而且$\lambda_1$和$\lambda_2$也很小，这个区域是平坦的。
- 当$R<0$且$\lambda_1 >> \lambda_2$或$\lambda_2 >> \lambda_1$，这个区域是边缘。
- 当R很大且$\lambda_1$和$\lambda_2$也很大，但$\lambda_1\sim\lambda_2$，这个区域是一个边角。

它可以用一张漂亮的图片来表示：

![image](images/harris_region.jpg)

所以Harris角点检测的结果是一张包含了这些分数的灰度图像，取图像超过一个阈值的部分，你会得到图片的边角。我们将会在一张简单的图片上实践一下。

## OpenCV中的Harris角点检测

OpenCV 有 `cv2.cornerHarris()`函数来进行Harris角点检测。

参数如下：

- `img` - 输入图片,它应该是灰度图，类型应该是`float32` 。
- `blockSize` - 角点检测考虑的区域大小
- `ksize` - 使用Sobel求导数时使用的光圈参数
- `k` - 方程中Harris检测器的自由参数

下面是样例代码：

```python
import cv2
import numpy as np
filename = 'chessboard.png'
img = cv2.imread(filename)
gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
gray = np.float32(gray)
dst = cv2.cornerHarris(gray,2,3,0.04)
# 结果被膨胀来显示出边缘，这不重要
dst = cv2.dilate(dst,None)
# 取图像超过一个最优化的阈值的部分，阈值根据图像会有所不同
img[dst>0.01*dst.max()]=[0,0,255]
cv2.imshow('dst',img)
if cv2.waitKey(0) & 0xff == 27:
    cv2.destroyAllWindows()
```

下面是三个结果：

![image](images/harris_result.jpg)

## 亚像素精确度级别的角点检测

有时候，你可能需要找到最准确的边角。 OpenCV带有一个函数	`cv2.cornerSubPix()`，它进一步细化了以亚像素精度检测到的角点。 下面是一个例子。 像往常一样，我们需要先找到Harris角点。 然后我们通过这些角的质心（一个角点可能包含多个像素，我们取它们的质心）来改进它们。 Harris角点用红色像素标出，改进过的角点用绿色像素标出。 对于这个函数，我们必须定义何时停止迭代。 我们在达到指定的迭代次数或达到一定的准确度后停止，以先达到者为准。 我们还需要定义要搜索角点的邻域的大小。

```python
import cv2
import numpy as np
filename = 'chessboard2.jpg'
img = cv2.imread(filename)
gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
# 寻找Harris角点
gray = np.float32(gray)
dst = cv2.cornerHarris(gray,2,3,0.04)
dst = cv2.dilate(dst,None)
ret, dst = cv2.threshold(dst,0.01*dst.max(),255,0)
dst = np.uint8(dst)
# 寻找质心
ret, labels, stats, centroids = cv2.connectedComponentsWithStats(dst)
# 定义停止标准并改进角点
criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 100, 0.001)
corners = cv2.cornerSubPix(gray,np.float32(centroids),(5,5),(-1,-1),criteria)
# 把它们画出来
res = np.hstack((centroids,corners))
res = np.int0(res)
img[res[:,1],res[:,0]]=[0,0,255]
img[res[:,3],res[:,2]] = [0,255,0]
cv2.imwrite('subpixel5.png',img)
```

下面是运行结果，为了结果清晰，一些重要的位置被放大了：

![image](images/subpixel3.png)

[^1]: http://www.bmva.org/bmvc/1988/avc-88-023.pdf 

