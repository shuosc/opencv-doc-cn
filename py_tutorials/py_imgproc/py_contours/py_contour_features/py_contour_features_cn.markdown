# 轮廓特征{#tutorial_py_contour_features_cn}

## 目标

在这篇文章中，我们将学习

- 找出轮廓的不同特征，如面积，周长，质心，边界框等。
- 您将看到许多与轮廓相关的功能。

1. 特征矩

   图像的特征矩可帮助您计算一些特征，如对象的质心，对象的面积等。请查看的维基百科页面[特征矩](http://en.wikipedia.org/wiki/Image_moment)。

   函数`cv2.moments()`给出了计算的所有特征矩的字典。见下面的代码：

   ```python
   import cv2
   import numpy as np

   img = cv2.imread('star.jpg',0)
   ret,thresh = cv2.threshold(img,127,255,0)
   im2,contours,hierarchy = cv2.findContours(thresh, 1, 2)
   cnt = contours[0]
   M = cv2.moments(cnt)
   print( M )
   ```

   从里开始，您可以提取有用的数据，如面积，质心等。质心由关系给出：$C_x = \frac {M_ {10}} {M_ {00}}$和$C_y = \frac {M_ {01}} { M_ {00}}$。这可以用如下方法完成：

   ```python
   cx = int(M['m10']/M['m00'])
   cy = int(M['m01']/M['m00'])
   ```

2. 轮廓区域

   轮廓区域由函数`cv2.contourArea()`给出，或者可以从图像矩`M ['m00']`中得到。

   ```python
   area = cv2.contourArea(cnt)
   ```

3. 轮廓周长
   它也被称为弧长。可以使用`cv2.arcLength()`函数找到它。第二个参数指定形状是封闭的轮廓（如果传入`True`），或者只是一条曲线。

   ```python
   perimeter = cv2.arcLength(cnt,True)
   ```

4. 轮廓近似
    它根据我们指定的精度将轮廓形状近似为具有较少顶点数的其他形状。它是[Douglas-Peucker算法](http://en.wikipedia.org/wiki/Ramer-Douglas-Peucker_algorithm)的一个实现。维基百科上有算法和演示。

    为了理解这一点，假设你试图在图像中找到一个正方形，但是由于图像中的一些问题，你没有得到一个完美的正方形，而是一个“坏形状”（如下图所示）。现在，您可以使用此功能来近似形状。在此，第二个参数称为`epsilon`，它是从轮廓到近似轮廓的最大距离。这是一个精确度参数。需要明智的选择`epsilon`来获得正确的输出。

    ```python
    epsilon = 0.1*cv2.arcLength(cnt,True)
    approx = cv2.approxPolyDP(cnt,epsilon,True)
    ```

    下面，在第二个图像中，绿线显示 epsilon = 10％弧长的近似曲线。

    第三张图片显示了epsilon = 1％弧长的情况。第三个参数指定曲线是否关闭。

5. 凸包

    凸包看起来与轮廓近似类似，但它们不是完全一样的（虽然两者在某些情况下可能确实会提供相同的结果）。`cv2.convexHull()`函数用来检查曲线的凸度缺陷并纠正它。一般来说，凸曲线总是凸出或者至少是平坦的曲线。如果它内部凸起，则称为凸面缺陷。例如，检查下面的图像的手。红线显示手的凸包。双面箭头标记显示凸面缺陷，这是凸包与轮廓的局部最大偏差。

    ![image](images/convexitydefects.jpg)

    ​

    关于这个函数的语法有一些事情要讨论：

    ```python
    hull = cv2.convexHull(points[, hull[, clockwise[, returnPoints]]
    ```

    参数详情：

    - `points`是我们传入的轮廓。
    - `hull`是输出，通常我们不使用这个参数（而使用返回值）。
    - `clockwise`：方向标志。如果为`True`，则输出顺时针方向的凸包。否则，输出逆时针方向的凸包。
    - `returnPoints`：默认情况下，为`True`。它会返回凸包的坐标。如果为`False`，返回凸包点对应的轮廓点的坐标。

    所以要得到如上图中的凸包，像以下这么做就足够了：

    ```python
    hull = cv2.convexHull(cnt)
    ```

    但是如果你想找到凸包缺陷，你需要传递`returnPoints = False`。要理解这些内容，我们将采取上面的矩形图像。首先，我发现它的轮廓为cnt。现在我使用`returnPoints = True`找到它的凸包，我得到了以下值：

    `[[223]]，[[51 202]]，[[51 79]]，[[234 79]]`，这是矩形的四个角点。

    现在，如果使用`returnPoints = False`做同样的处理，会得到如下结果：`[[129]，[67]，[0]，[142]]`。

    这些是轮廓中对应点的坐标。例如，检查第一个值：

    `cnt [129] = [[234,202]]`与第一个结果相同（其他点也是这样）。

    当我们讨论凸包缺陷时，你会再次看到它。

6. 检查凸性

    有一个函数来检查曲线是否凸起，`cv2.isContourConvex()`。这个函数只返回`True`或`False`。这没什么大不了的。

    ```python
    k = cv2.isContourConvex(cnt)
    ```

7. 边界框

    有两种类型的边界框。

    - 直的边界矩形

      它是一个直的矩形，它不考虑对象的旋转。所以边界矩形的面积不会是最小的。它由函数`cv2.boundingRect()`发现。

      设(x,y)为矩形的左上角坐标，(w,h)为其宽度和高度。

      ```python
      x,y,w,h = cv2.boundingRect(cnt)
      cv2.rectangle(img,(x,y),(x+w,y+h),(0,255,0),2)
      ```

    - 旋转的边界矩形

      这里，边界矩形是根据最小面积绘制的，所以它也考虑了旋转。使用的函数是`cv2.minAreaRect()`。它返回一个Box2D结构，其中包含以下结构 - (center(x,y),(width，height), angle of rotation)。但要绘制这个矩形，我们需要矩形的四个角。它是通过函数`cv2.boxPoints()`获得的。

      ```python
      rect = cv2.minAreaRect(cnt)
      box = cv2.boxPoints(rect)
      box = np.int0(box)
      cv2.drawContours(img,[box],0,(0,0,255),2)
      ```

      两个矩形都显示在一个图像中。绿色矩形显示正常的边界矩形。红色的矩形是旋转的矩形。

8. 最小闭圆

    接下来我们使用函数`cv2.minEnclosingCircle()`来找到对象的外接圆。 它是一个完全覆盖面积最小的物体的圆。

    ```python
    (x,y),radius = cv2.minEnclosingCircle(cnt)
    center = (int(x),int(y))
    radius = int(radius)
    cv2.circle(img,center,radius,(0,255,0),2)
    ```

    ![image](images/circumcircle.png)

9. 拟合椭圆

   接下来是将椭圆拟合到一个对象。 它将返回椭圆所在的旋转矩形。

   ```python
   ellipse = cv2.fitEllipse(cnt)
   cv2.ellipse(img,ellipse,(0,255,0),2)
   ```

   ![image](images/fitellipse.png)

10. 拟合一条线
  同样，我们可以将一条线放在一组点上。 下面的图像包含一组白点。 我们可以拟合一条直线。

  ```python
  rows,cols = img.shape[:2]
  [vx,vy,x,y] = cv2.fitLine(cnt, cv2.DIST_L2,0,0.01,0.01)
  lefty = int((-x*vy/vx) + y)
  righty = int(((cols-x)*vy/vx)+y)
  cv2.line(img,(cols-1,righty),(0,lefty),(0,255,0),2)
  ```

  ​

