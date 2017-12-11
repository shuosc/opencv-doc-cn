# 光流{#tutorial_py_lucas_kanade_cn}

## 目标

在这一章当中，

- 我们将理解光流的概念及使用Lucas-Kanade方法估计光流。
- 我们将使用像`cv2.calcOpticalFlowPyrLK()`这样的函数来跟踪视频中的特征点。

## 光流

光流是由物体或相机的运动引起的图像对象在两个连续帧之间的视在运动模式。它是2D矢量场，其中每个矢量是一个位移矢量，表示点从第一帧到第二帧的移动。考虑下面的图片（图片提供：[维基百科关于光流的文章](https://zh.wikipedia.org/wiki/光流法)）。

![image](images/optical_flow_basic1.jpg)

它显示了一个连续5帧移动的球。箭头显示其位移矢量。光流在许多领域中有应用，像：

- 动作结构
- 视频压缩
- 视频稳定
- ……

光流在几个假设下工作：

- 对象的像素强度在连续的帧之间不会改变。
- 相邻像素具有相似的运动。

考虑第一帧中的一个像素$I(x,y,t)$（一个新的维度，时间，在这里被添加进来，之前我们只处理静态图像，所以不需要时间）。它在$dt$时间之后的下一帧中移动距离$(dx,dy)$ 。因此，由于这些像素是相同的，而且强度不变，所以我们可以说：
$$
I(x,y,t) = I(x+dx, y+dy, t+dt)
$$
对右边进行台了展开，移除常数项并除以$dt$，会得到：
$$
f_x u + f_y v + f_t = 0\\
where\\
f_x = \frac{\partial f}{\partial x} \\ 2f_y = \frac{\partial f}{\partial y}\\ 3u = \frac{dx}{dt} \\ 4v = \frac{dy}{dt}
$$
以上等式称为光流方程。在这里，我们可以找到$f_x$和$f_y$，它们是图像梯度。同样，$f_t$是沿着时间方向上的的梯度。但$(u,v)$是未知的。我们不能在有两个未知的变量的条件下解这个方程。有几种方法可以解决这个问题，其中之一就是Lucas-Kanade方法。

## Lucas-Kanade方法

之前我们已经假设了所有的相邻像素都会有相似的运动。Lucas-Kanade方法需要一个3x3的块。9点都有相同的动作。我们可以找到这9个点的$(f_x, f_y, f_t)$。所以现在我们的问题就是求解9个有两个未知变量的方程。一个更好的方法是用最小二乘法拟合。下面是两个方程-两个未知量的最终解决方案，解这个方程来得到最终的解。
$$
\begin{bmatrix} u \\ v \end{bmatrix} =
\begin{bmatrix}
    \sum_{i}{f_{x_i}}^2  &  \sum_{i}{f_{x_i} f_{y_i} } \\
    \sum_{i}{f_{x_i} f_{y_i}} & \sum_{i}{f_{y_i}}^2
\end{bmatrix}^{-1}
\begin{bmatrix}
    - \sum_{i}{f_{x_i} f_{t_i}} \\
    - \sum_{i}{f_{y_i} f_{t_i}}
\end{bmatrix}
$$
（看看这里的逆矩阵与Harris角点检测器的相似性。这也证明了角点是更好的跟踪用的点。）

所以从用户的角度来看，思路很简单，我们给出一些跟踪点，我们得到这些点的光流向量。但是也有一些问题。到现在为止，我们都在处理小规模的运动。当运动很大时这就会失败。所以我们再使用图像金字塔。当我们向金字塔上方走时，小的运动会被移除，大的运动会变成小的运动。因此，在那里应用Lucas-Kanade法，我们可以得到缩放过的光流。

## OpenCV中的Lucas-Kanade光流

OpenCV在一个函数`cv2.calcOpticalFlowPyrLK()`中提供了所有这些。在这里，我们创建一个简单的应用程序，跟踪视频中的一些点。为了决定要跟踪的点，我们使用`cv2.goodFeaturesToTrack()`。我们取第一帧，检测一些Shi-Tomasi角点，然后用Lucas-Kanade光流迭代地跟踪这些点。对于函数`cv2.calcOpticalFlowPyrLK()`，我们传递前一帧，前面的点和下一帧。如果找到下一个点，则返回下一个点以及一些状态值为1的值，否则为零。我们迭代地将这些下一个点作为下一个步骤的前几个点。请参阅下面的代码：

```python
import numpy as np
import cv2

cap = cv2.VideoCapture('slow.flv')

# ShiTomasi角点检测参数
feature_params = dict( maxCorners = 100,
                       qualityLevel = 0.3,
                       minDistance = 7,
                       blockSize = 7 )

# lucas kanade光流参数
lk_params = dict( winSize  = (15,15),
                  maxLevel = 2,
                  criteria = (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03))

# 一些随机颜色
color = np.random.randint(0,255,(100,3))

# 取第一帧，寻找角点
ret, old_frame = cap.read()
old_gray = cv2.cvtColor(old_frame, cv2.COLOR_BGR2GRAY)
p0 = cv2.goodFeaturesToTrack(old_gray, mask = None, **feature_params)

# 创建一个mask，为了绘图方便
mask = np.zeros_like(old_frame)

while(1):
    ret,frame = cap.read()
    frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    
    # 计算光流
    p1, st, err = cv2.calcOpticalFlowPyrLK(old_gray, frame_gray, p0, None, **lk_params)
    
    # 选择较好的点
    good_new = p1[st==1]
    good_old = p0[st==1]
    
    # 画出轨迹
    for i,(new,old) in enumerate(zip(good_new,good_old)):
        a,b = new.ravel()
        c,d = old.ravel()
        mask = cv2.line(mask, (a,b),(c,d), color[i].tolist(), 2)
        frame = cv2.circle(frame,(a,b),5,color[i].tolist(),-1)
    img = cv2.add(frame,mask)
    
    cv2.imshow('frame',img)
    k = cv2.waitKey(30) & 0xff
    if k == 27:
        break
    
    # 更新前面的帧和点
    old_gray = frame_gray.copy()
    p0 = good_new.reshape(-1,1,2)

cv2.destroyAllWindows()
cap.release()
```

（这个代码并没有检查下一个关键点的正确性，所以即使任何特征点在图像中消失了，光流也有可能找到可能看起来接近它的下一个点。所以要做一个健壮的追踪程序的话，就要在特定的时间间隔内检测一次角点，OpenCV示例中每隔5帧就会采集一次样本，找出特征点，并对所得到的光学流点进行反向检查，只选择好的样本点，见samples/python/lk_track.py）。

下面是我们的到的结果：

![image](images/opticalflow_lk.jpg)

# OpenCV中的密集光流

Lucas-Kanade方法计算稀疏特征集的光流（在我们的例子中，使用Shi-Tomasi算法检测角点）。 OpenCV提供了另一种算法来查找密集光流。它计算帧中所有点的光流。它基于Gunner Farneback的算法，该算法在Gunner Farneback于2003年的《Two-Frame Motion Estimation Based on Polynomial Expansion》中有所解释。

以下示例显示如何使用上述算法找到密集的光流。我们得到一个带有光流矢量的双通道阵列，$(u,v)$。我们查找他们的幅度和方向。我们对结果进行颜色编码以实现更好的可视化。方向对应于图像的色调值。 幅度对应于价值平面。 请参阅下面的代码：

```python
import cv2
import numpy as np
cap = cv2.VideoCapture("vtest.avi")

ret, frame1 = cap.read()
prvs = cv2.cvtColor(frame1,cv2.COLOR_BGR2GRAY)
hsv = np.zeros_like(frame1)
hsv[...,1] = 255

while(1):
    ret, frame2 = cap.read()
    next = cv2.cvtColor(frame2,cv2.COLOR_BGR2GRAY)
    
    flow = cv2.calcOpticalFlowFarneback(prvs,next, None, 0.5, 3, 15, 3, 5, 1.2, 0)
    
    mag, ang = cv2.cartToPolar(flow[...,0], flow[...,1])
    hsv[...,0] = ang*180/np.pi/2
    hsv[...,2] = cv2.normalize(mag,None,0,255,cv2.NORM_MINMAX)
    bgr = cv2.cvtColor(hsv,cv2.COLOR_HSV2BGR)
    
    cv2.imshow('frame2',bgr)
    k = cv2.waitKey(30) & 0xff
    if k == 27:
        break
    elif k == ord('s'):
        cv2.imwrite('opticalfb.png',frame2)
        cv2.imwrite('opticalhsv.png',bgr)
    prvs = next

cap.release()
cv2.destroyAllWindows()
```

下面是结果：

![image](images/opticalfb.jpg)

OpenCV在密集光流上有一个高级的示例，请参阅samples/python/opt_flow.py。

## 练习

- 查看samples/python/lk_track.py中的代码。尝试理解代码。
- 查看samples/python/opt_flow.py中的代码。尝试理解代码。