# Meanshift和Camshift {#tutorial_py_meanshift_cn}

## 目标

在这一章当中，

- 我们将学习使用Meanshift和Camshift算法来查找和跟踪视频中的对象。

## Meanshift

Meanshift背后的想法很简单。 考虑你有一组点。 （它可以是像直方图反投影那样的像素分布）。 给出一个小窗口（可能是一个圆圈），你必须将窗口移动到最大像素密度（或最多点数）的区域。 下面给出了简单的图像：

![image](images/meanshift_basics.jpg)

初始窗口是蓝色圆圈“C1”。 它的原始中心被标记为蓝色矩形，名为“C1\_o”。 但是如果你寻找窗口内的点的质心，你会得到点“C1\_r”（用小蓝圈标记），这是窗口的真实质心。 当然，他们不匹配。 所以，移动你的窗口，使新圆与以前的质心匹配。 再次找到新的质心。 最有可能的情况是，它还是不匹配。 所以再次移动它，继续迭代，使得窗口的中心和它的质心落在相同的位置（或者只有很小的期望误差）。 所以最后你得到的是一个最大像素分布的窗口。 标有绿色圆圈，名为“C2”。 正如你在图像中看到的，它有最多的点数。 整个过程在下面的图像中演示：

![image](images/meanshift_face.gif)

## OpenCV中的Meanshift

为了在OpenCV中使用meanshift，首先我们需要设置目标，找到它的直方图，以便我们可以在每个帧上使用反向投影以计算meanshift。 我们还需要提供窗口的初始位置。 对于直方图，这里只考虑色调。 此外，为了避免由于低光照造成的错误值，要先使用`cv2.inRange()`函数丢弃低亮度值。

```python
import numpy as np
import cv2

cap = cv2.VideoCapture('slow.flv')

# 取视频第一帧
ret,frame = cap.read()

# 设置窗口的初始位置
r,h,c,w = 250,90,400,125  # 简单地使用硬编码的值
track_window = (c,r,w,h)

# 简单地使用硬编码的值
roi = frame[r:r+h, c:c+w]
hsv_roi =  cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
mask = cv2.inRange(hsv_roi, np.array((0., 60.,32.)), np.array((180.,255.,255.)))
roi_hist = cv2.calcHist([hsv_roi],[0],mask,[180],[0,180])
cv2.normalize(roi_hist,roi_hist,0,255,cv2.NORM_MINMAX)

# 设置终止条件，10次迭代或者只移动1个pt
term_crit = ( cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 1 )

while(1):
    ret ,frame = cap.read()

    if ret == True:
        hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        dst = cv2.calcBackProject([hsv],[0],roi_hist,[0,180],1)
    
        # 进行一次MeanShift来找到新的窗口位置
        ret, track_window = cv2.meanShift(dst, track_window, term_crit)
    
        # 画到图像上
        x,y,w,h = track_window
        img2 = cv2.rectangle(frame, (x,y), (x+w,y+h), 255,2)
        cv2.imshow('img2',img2)
    
        k = cv2.waitKey(60) & 0xff
        if k == 27:
            break
        else:
            cv2.imwrite(chr(k)+".jpg",img2)
    
    else:
        break

cv2.destroyAllWindows()
cap.release()
```

我使用的视频中的三个帧如下所示：

![image](images/meanshift_result.jpg)

## Camshift

你有没有仔细看过上一个结果？ 有一个问题。 无论在车距离摄像头较远时还是较近时，我们的车窗总是有相同的大小。 这是不好的。 我们需要根据目标的大小和旋转来调整窗口大小。 这个解决方案再一次来自于“OpenCV实验室”，它由Gary Bradsky在他1988年的论文《Computer Vision Face Tracking for Use in a Perceptual User Interface》中被称为CAMshift（连续自适应Meanshift）。

它首先应用Meanshift。 一旦meanshift收敛，它将窗口大小更新为$s = 2 \times \sqrt {\frac {M_{00}} {256}}$。 它也计算最佳拟合椭圆的方向。 同样，它将新的缩放过的搜索窗口和之前的窗口位置应用于方法转换。 这个过程一直持续到满足要求的准确度。

### OpenCV中的Camshift

它和meanshift几乎相同，但是它返回一个旋转的矩形（这是我们的结果）和box参数（在下一次迭代时用作搜索窗口）。 请参阅下面的代码：

```python
import numpy as np
import cv2

cap = cv2.VideoCapture('slow.flv')

# 取视频第一帧
ret,frame = cap.read()

# 设置窗口的初始位置
r,h,c,w = 250,90,400,125  # 简单地使用硬编码的值
track_window = (c,r,w,h)

# 设置ROI
roi = frame[r:r+h, c:c+w]
hsv_roi =  cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
mask = cv2.inRange(hsv_roi, np.array((0., 60.,32.)), np.array((180.,255.,255.)))
roi_hist = cv2.calcHist([hsv_roi],[0],mask,[180],[0,180])
cv2.normalize(roi_hist,roi_hist,0,255,cv2.NORM_MINMAX)

# 设置终止条件，10次迭代或者只移动1个pt
term_crit = ( cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 1 )

while(1):
    ret ,frame = cap.read()

    if ret == True:
        hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        dst = cv2.calcBackProject([hsv],[0],roi_hist,[0,180],1)
    
        # 进行一次MeanShift来找到新的窗口位置
        ret, track_window = cv2.CamShift(dst, track_window, term_crit)
    
        # 画到图像上
        pts = cv2.boxPoints(ret)
        pts = np.int0(pts)
        img2 = cv2.polylines(frame,[pts],True, 255,2)
        cv2.imshow('img2',img2)
    
        k = cv2.waitKey(60) & 0xff
        if k == 27:
            break
        else:
            cv2.imwrite(chr(k)+".jpg",img2)
    
    else:
        break

cv2.destroyAllWindows()
cap.release()
```

下面是结果：

![image](images/camshift_result.jpg)

## 更多资源

-  [Camshift](http://fr.wikipedia.org/wiki/Camshift)的法文wiki页面。 (两幅动图就是从这里拿来的)
-  Bradski, G.R., 《[Real time face and object tracking as a component of a perceptual user interface](http://ieeexplore.ieee.org/iel4/5940/15812/00732882.pdf)》 Applications of Computer Vision, 1998. WACV '98. Proceedings., Fourth IEEE Workshop on , vol., no., pp.214,219, 19-21 Oct 1998

## 练习

OpenCV中附带一个Python示例进行了camshift的交互式演示。 使用它，hack它并理解它。