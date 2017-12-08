# 轮廓特性{#tutorial_py_contour_properties_cn}

在这里，我们将学习提取对象的一些常用属性，像Solidity，Equivalent Diameter，Mask image，Mean Intensity等。更多的特性可以在Matlab的regionprops文档中找到。

（另外：Centroid，Area，Perimeter等也属于这个类别，但是我们在上一章已经学过了）

1. 长宽比

   它是对象边界矩的宽高比。
   $$
   Aspect \; Ratio = \frac{Width}{Height}
   $$

   ```python
   x,y,w,h = cv2.boundingRect(cnt)
   aspect_ratio = float(w)/h
   ```

2. Extent

   Extent是轮廓面积与边界矩形面积的比值。

   $$
    Extent = \frac{Object \; Area}{Bounding \; Rectangle \; Area}
   $$

    ```python
    area = cv2.contourArea(cnt)
    x,y,w,h = cv2.boundingRect(cnt)
    rect_area = w*h
    extent = float(area)/rect_area
    ```

3. Solidity

   Solidity是轮廓面积与凸包面积的比率。
   $$
   Solidity = \frac{Contour \; Area}{Convex \; Hull \; Area}
   $$

   ```python
   area = cv2.contourArea(cnt)
   hull = cv2.convexHull(cnt)
   hull_area = cv2.contourArea(hull)
   solidity = float(area)/hull_area
   ```

4. Equivalent Diameter

   Equivalent Diameter是与轮廓面积相同的圆的直径。
   $$
   Equivalent \; Diameter = \sqrt{\frac{4 \times Contour \; Area}{\pi}}
   $$

   ```python
   area = cv2.contourArea(cnt)
   equi_diameter = np.sqrt(4*area/np.pi)
   ```

5. 方向

   方向是物体指向的角度。以下的方法也给出了长轴和短轴的长度。

   ```python
   (x,y),(MA,ma),angle = cv2.fitEllipse(cnt)
   ```

6. Mask和Pixel Points

   在某些情况下，我们可能需要包含该对象的所有点。我们可以这么做：

   ```python
   mask = np.zeros(imgray.shape,np.uint8)
   cv2.drawContours(mask,[cnt],0,255,-1)
   pixelpoints = np.transpose(np.nonzero(mask))
   # pixelpoints = cv2.findNonZero(mask)
   ```

   ​

   这里有两个方法，一个使用Numpy函数，另一个使用OpenCV函数（最后一个注释行）它们所做的事情基本相同。结果也几乎是一样的，只有一个微小的差别。 Numpy给出**(row, column)**的坐标，而OpenCV以**(x,y)**格式给出坐标。所以答案会反。请注意，**row = x**，**column = y**。

7. 最大值，最小值及其位置

   我们可以使用mask image找到这些参数。

   ```python
   min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(imgray,mask = mask)
   ```

8. 平均颜色或平均亮度

   在这里，我们可以找到一个物体的平均颜色。或者在灰度图像中就是是对象的平均量度。我们再次使用相同的mask来做到这一点。

   ```python
   mean_val = cv2.mean(im,mask = mask)
   ```

9. 至点
    至点就是对象的最上面，最下面，最右边和最左边的点。
    ```python
    leftmost = tuple(cntcnt[:,:,0].argmin())
    rightmost = tuple(cntcnt[:,:,0].argmax())
    topmost = tuple(cntcnt[:,:,1].argmin())
    bottommost = tuple(cntcnt[:,:,1].argmax())
    ```
    例如，如果我将它应用到印度地图，会得到以下结果：
    ![image](images/extremepoints.jpg)

## 练习
- matlab regionprops doc中还有一些特性。尝试实现它们。


