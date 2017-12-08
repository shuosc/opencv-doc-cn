# 轮廓：更多函数{#tutorial_py_contours_more_functions_cn}

## 目标

在这一章中，我们将学习

     - 凸面缺陷以及如何找到它们。
     - 找到一个点到多边形的最短距离
     - 匹配不同的形状

## 理论基础与代码

1. ### 凸包缺陷

   我们在第二章中看到什么是凸包。物体与该凸包之间的任何偏差均可视为凸包缺陷。

   OpenCV提供了一个现成的函数来找到凸包缺陷`cv2.convexityDefects()`。基本的函数调用如下所示：

   ```python
   hull = cv2.convexHull(cnt,returnPoints = False)
   defects = cv2.convexityDefects(cnt,hull)
   ```

   记住我们必须在寻找凸面缺陷时，传递`returnPoints = False`给用来寻找找凸包的函数`cv2.convexHull`。

   它返回一个数组，每行包含这些值 - `[起点，终点，最远点，到最远点的近似距离]`。我们可以使用图像对其进行可视化。我们可以画一条连线起点和终点，然后在最远点画一个圆。记得前三个返回的值是cnt的索引。所以我们必须从cnt中提取这些值。

   ```python
   import cv2
   import numpy as np

   img = cv2.imread('star.jpg')
   img_gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
   ret,thresh = cv2.threshold(img_gray, 127, 255,0)
   im2,contours,hierarchy = cv2.findContours(thresh,2,1)
   cnt = contours[0]

   hull = cv2.convexHull(cnt,returnPoints = False)
   defects = cv2.convexityDefects(cnt,hull)

   for i in range(defects.shape[0]):
       s,e,f,d = defects[i,0]
       start = tuple(cnt[s][0])
       end = tuple(cnt[e][0])
       far = tuple(cnt[f][0])
       cv2.line(img,start,end,[0,255,0],2)
       cv2.circle(img,far,5,[0,0,255],-1)

   cv2.imshow('img',img)
   cv2.waitKey(0)
   cv2.destroyAllWindows()
   ```

   下面是结果：

   ![image](images/defects.jpg)

2. 点-多边形测试

   OpenCV中的`pointPolygonTest`函数可以找到图像中的一个点与轮廓之间的最短距离。当点在轮廓外时，返回负值的距离，点在内部时返回正值，如果点在轮廓上，则返回零。

   例如，我们可以像这样检查点(50,05)：

   ```python
   dist = cv2.pointPolygonTest(cnt,(50,50),True)
   ```

   在函数中，第三个参数是`measureDist`。如果它是`True`，它会找到有符号的距离。如果为False，则会查找该点是在内部还是外部还是在轮廓上（它分别返回+1，-1，0）。

   如果不想查找距离，请确保第三个参数是False，因为这是一个耗时的过程。所以，传入`False`的速度将会是传入`True`2-3倍。

3. 匹配形状

   OpenCV有一个函数`cv2.matchShapes()`，它使我们能够比较两个形状或两个轮廓，并返回一个显示相似性的度量。这个值越低，结果就越好。

   它是根据hu-特征矩值来计算的。文档中解释了不同的测量方法。

   ```python
   import cv2
   import numpy as np

   img1 = cv2.imread('star.jpg',0)
   img2 = cv2.imread('star2.jpg',0)

   ret, thresh = cv2.threshold(img1, 127, 255,0)
   ret, thresh2 = cv2.threshold(img2, 127, 255,0)
   im2,contours,hierarchy = cv2.findContours(thresh,2,1)
   cnt1 = contours[0]
   im2,contours,hierarchy = cv2.findContours(thresh2,2,1)
   cnt2 = contours[0]

   ret = cv2.matchShapes(cnt1,cnt2,1,0.0)
   print( ret )
   ```

   我试着匹配了下面给出的不同形状：

   ![image](images/matchshapes.jpg)

   我得到了以下结果：

   - 匹配图像A和其本身= 0.0
   - 匹配图像A和图像B = 0.001946
   - 匹配图像A和图像C = 0.326911

   看，图像旋转不会对这个匹配影响太多。

   [Hu-特征矩](http://en.wikipedia.org/wiki/Image_moment#Rotation_invariant_moments)是七个平移缩放和旋转无关的矩。其中一个是偏离无关的。这些值可以使用`cv2.HuMoments()`函数找到。

## 练习

- 查看`cv2.pointPolygonTest()`的文档，你可以找到一个很好的红色和蓝色的图像。它表示从所有像素到白色曲线的距离。曲线内的所有像素都是蓝色的，这取决于距离。同样曲线外的点是红色的。轮廓边缘用白色标记。写代码来创建这样的距离表示。

- 使用`cv2.matchShapes()`比较数字或字母的图像。 （这是制作OCR程序的一个简单方法）