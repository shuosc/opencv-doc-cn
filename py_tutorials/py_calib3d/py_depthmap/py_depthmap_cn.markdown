# 来自立体图像的深度图{#tutorial_py_depthmap_cn}

##目标

在这个章中，

- 我们将学习从立体图像创建深度图。

基本

在上一章中，我们看到了极线约束等相关术语的基本概念。我们也看到，如果我们有两个相同的场景图像，我们可以直观地从中获取深度信息。下面是一个图像和一些简单的数学公式，证明了这个直觉。

![image](images/stereo_depth.jpg)

上图包含全等三角形。写出它们的等价方程将得到以下结果：

$$
disparity = x - x' = \frac{Bf}{Z}
$$
$x$和$x'$是对应于场景点3D的图像平面中的点与其相机中心之间的距离。 $B$是两台摄像机之间的距离（这个距离我们已经是知道的），$f$是摄像机的焦距（也是已知的）。所以简而言之，上面的等式说明了一个场景中一个点的深度与相应的图像点和它们的相机中心之间的距离的差值成反比。因此，利用这些信息，我们可以导出图像中所有像素的深度。

所以它能找到两个图像之间的相应匹配。我们已经看到了极线约束如何使这个操作更快，更准确。一旦找到匹配，就会找到disparity。让我们看看我们如何使用OpenCV来做到这一点。

## 代码

下面的代码片段显示了创建disparity图的简单过程。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt

imgL = cv2.imread('tsukuba_l.png',0)
imgR = cv2.imread('tsukuba_r.png',0)

stereo = cv2.StereoBM_create(numDisparities=16, blockSize=15)
disparity = stereo.compute(imgL,imgR)
plt.imshow(disparity,'gray')
plt.show()
```



下面的图像包含原始图像（左）和它的视差图（右）。正如你所看到的，结果被高度的噪音污染。通过调整`numDisparities`和`blockSize`的值，可以获得更好的结果。

![image](images/disparity_map.jpg)

@note 更多细节需要被添加

## 练习

- OpenCV示例包含生成视差图及其三维重建的示例。查看OpenCV-Python示例中的stereo_match.py​​。