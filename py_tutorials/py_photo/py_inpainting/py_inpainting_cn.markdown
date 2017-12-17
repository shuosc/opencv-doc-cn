# 图像修复 {#tutorial_py_inpainting_cn}

##目标

在这一章当中，

- 我们将学习如何通过一种叫做“图像修复（inpainting）”的方法来去除旧照片中的小噪音，划痕等等
- 我们将看到OpenCV中的功能。

##基础知识

你们大多数人会在家里看到一些老旧的照片，上面有一些黑点，一些划痕等等。你有没有想过去修复它？我们不能简单地在绘画工具中抹去它们，因为它只是用白色的结构来代替黑色的结构，这是没有用的。在这些情况下，使用了一种称为图像修复的技术。基本的想法很简单：用相邻的像素替换那些不好的标记，使其看起来像其邻居。考虑下面显示的图片（取自[维基百科](https://zh.wikipedia.org/wiki/图像修复)）：

![image](images/inpaint_basics.jpg)

为此目的设计了几种算法，OpenCV提供了两种算法。两者都可以通过相同的函数`cv2.inpaint()`来访问

第一种算法是基于Alexandru Telea在2004年发表的论文《An Image Inpainting Technique Based on the Fast Marching Method》。它基于快速前进法。考虑图像中的将被修复的一个区域。算法从这个区域的边界开始，并在该区域内逐渐填充边界中的所有内容。在邻居的像素周围需要一个小的邻域进行修补。这个像素被邻域中所有已知像素的归一化加权和所取代。选择权重是一个重要的事情。对位于该点附近的那些像素，靠近边界的法线以及位于边界轮廓上的那些像素将会赋予更大的权重。一旦一个像素被修补，它将使用快速前进法移动到下一个最近的像素。 快速前进法确保已知像素附近的像素首先被修补，以便它像一个手动启发式操作一样工作。该算法通过使用标志`cv2.INPAINT_TELEA`来启用。

第二种算法是基于Bertalmio，Marcelo，Andrea L. Bertozzi和Guillermo Sapiro在2001年发表的《Navier-Stokes, Fluid Dynamics, and Image and Video Inpainting》论文。该算法基于流体动力学并利用偏微分方程。基本原理是启发式。它首先沿着已知区域的边缘行进到未知区域（因为边缘是连续的）。它继续等照度（连接相同强度点的线，就像轮廓连接具有相同高度的点），同时匹配修补区边界处的梯度向量。为此，使用流体动力学的一些方法。一旦获得，就会填充颜色以减少该区域的最小偏差。该算法通过使用标志`cv2.INPAINT_NS`来启用。

##代码

我们需要创建一个与输入图像大小相同的mask，其中非零像素对应于要被修补的区域。其他一切都很简单。我的图像中有一些黑色笔画（是我手动添加的）。我用Paint工具创建了相应的笔画。

```python
import numpy as np
import cv2

img = cv2.imread('messi_2.jpg')
mask = cv2.imread('mask2.png',0)

dst = cv2.inpaint(img,mask,3,cv2.INPAINT_TELEA)

cv2.imshow('dst',dst)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

看下面的结果。第一张图片显示degrade后的输入。第二个图像是mask。第三个图像是第一个算法的结果，最后一个图像是第二个算法的结果。



##更多资源

- Bertalmio，Marcelo，Andrea L. Bertozzi和Guillermo Sapiro。《Navier-stokes, fluid dynamics, and image and video inpainting》。在Computer Vision and Pattern Recognition, 2001. CVPR 2001. Proceedings of the 2001 IEEE Computer Society Conference on, vol. 1, pp. I-355. IEEE, 2001.
- Telea, Alexandru. 《An image inpainting technique based on the fast marching method》 Journal of graphics tools 9.1 (2004): 23-34.

##练习

- OpenCV带有一个关于图像修复的交互式例子代码，samples/python/inpaint.py，试试吧。
- 几个月前，我观看了Adobe Photoshop中使用的高级修补技术[Content-Aware Fill](http://www.youtube.com/watch?v=ZtoUiplKa2A)的视频。在进一步的搜索，我能够发现，同样的技术已经在GIMP有不同的名称，“Resynthesizer”（你需要安装单独的插件）。我相信你会喜欢这项技术。