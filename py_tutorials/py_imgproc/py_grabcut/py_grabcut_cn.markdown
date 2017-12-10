# 使用GrabCut算法交互式前景提取{#tutorial_py_grabcut_cn}

## 目标

在这一章当中

- 我们将看到GrabCut算法提取图像中的前景
- 我们将为此创建一个交互式应用程序。

理论

GrabCut算法由英国剑桥微软研究院的Carsten Rother，Vladimir Kolmogorov和Andrew Blake设计。在他们的论文["GrabCut": interactive foreground extraction using iterated graph cuts](http://dl.acm.org/citation.cfm?id=1015720)中。如果你需要一个只需要最少量用户交互的前景提取算法，那么GrabCut就是你所需要的。

从用户的角度来看它是如何工作的？最初用户围绕着前景区域绘制一个矩形（前景区域应该完全在矩形内）。然后算法对其进行迭代分割以获得最佳结果。但在某些情况下，分割不会很好，例如，它可能标记了一些前景区域作为背景，或反之。在这种情况下，用户需要做一些修改。只需在图像上点击一些错误的结果就可以了。基本上是这样的：“嘿，这个区域应该是前景的，你把它标记为背景，在下一次迭代中纠正它”，或者对于背景来说正相反。然后在下一次迭代中，你会得到更好的结果。

看到下面的图片。一开始球员和足球被围在一个蓝色的矩形中。然后做一些白色笔画（表示前景）和黑色笔画（表示背景）的修饰。

我们得到一个不错的结果。

![image](images/grabcut_output1.jpg)

那么后台发生了什么？

- 用户输入矩形。这个矩形之外的所有东西都将被视为确定的背景（这就是之前提到你的矩形应该包含所有对象的原因）。矩形内的所有东西都是未知的。类似地，任何指定前景和背景的用户输入都被认为是硬标签，这意味着它们在该过程中不会改变。
- 计算机根据我们提供的数据进行初始标注。它标记前景和背景像素（或硬标签）
- 现在使用高斯混合模型（GMM）来模拟前景和背景。
- 根据我们提供的数据，GMM学习并创建新的像素分布。也就是说，未知像素在颜色统计方面根据其与其他硬标记像素之间的关系被标记为可能的前景或可能的背景（就像聚类一样）。
- 从这个像素分布构建一个图形。图中的节点是像素。另外增加两个节点，**Source节点**和**Sink节点**。每个前景像素连接到Source节点，每个背景像素连接到Sink节点。
- 将像素连接到Sorce节点/Sink节点的边的权重由像素为前景/背景的概率定义。像素之间的权重由边缘信息或像素相似性定义。如果像素颜色差异很大，那么它们之间的边的权值将会变得很低。
  然后使用mincut算法来分割图形。它将图形切割成两个分离的源节点和最小代价函数的汇聚节点。成本函数是剪切边的所有权重的总和。剪切之后，连接到源节点的所有像素变为前景，连接到源节点的像素变为背景。
- 过程一直持续到分类收敛。

如下图所示（图片提供者：http://www.cs.ru.ac.za/research/g02m1682/）

![image](images/grabcut_scheme.jpg)

## 演示

现在我们开始使用OpenCV中的的grabcut算法。 OpenCV有这个函数：`cv2.grabCut()`。我们首先来看看它的参数：

- `img` - 输入图像
- `mask`-这是一个mask图像，我们指定哪些区域是背景，前景或可能的背景/前景等。它由以下标志完成：`cv2.GC_BGD`，`cv2.GC_FGD`，`cv2.GC_PR_BGD`，`cv2.GC_PR_FGD`或简单地将0,1,2,3传递给图像。
- `rect` - 它是矩形的坐标，格式为（x，y，w，h），其中包括前景对象。
- `bdgModel`，`fgdModel` - 这是内部算法使用的数组。您只需创建两个大小为(1,65)的np.float64类型的全零数组。
- `iterCount` - 算法应该运行的迭代次数。
- `mode` - 它应该是`cv2.GC_INIT_WITH_RECT`或`cv2.GC_INIT_WITH_MASK`或其组合，这个参数决定我们是否绘制矩形或最终的触觉笔触。

首先让我们看看`GC_INIT_WITH_RECT`模式。我们加载图像，创建一个类似的蒙版图像。我们创建`fgdModel`和`bgdModel`。我们给矩形参数。这些都是是直截了当的。让算法运行5次。由于我们使用的是矩形，所以模式应该是`cv2.GC_INIT_WITH_RECT`。然后运行grabCut。它会修改蒙版图像。在新的蒙版图像中，像素将被标记为具有如上所述的表示背景/前景的四个标记。所以我们修改mask，使所有的0像素和2像素被置为0（即背景），并且所有1像素和3像素被置于1（即前景像素）。现在我们最后的mask已经准备好了，只要将它与输入图像相乘即可获得分割过的图像。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt

img = cv2.imread('messi5.jpg')
mask = np.zeros(img.shape[:2],np.uint8)
bgdModel = np.zeros((1,65),np.float64)
fgdModel = np.zeros((1,65),np.float64)
rect = (50,50,450,290)
cv2.grabCut(img,mask,rect,bgdModel,fgdModel,5,cv2.GC_INIT_WITH_RECT)
mask2 = np.where((mask2)|(mask0),0,1).astype('uint8')
img = img*mask2[:,:,np.newaxis]
plt.imshow(img),plt.colorbar(),plt.show()
```

看下面的结果：

![image](images/grabcut_rect.jpg)

哎呀，梅西的头发不见了。谁喜欢没有头发的梅西？我们需要把它弄回来。所以我们会给出一个很好的值为1的像素的修正（确定前景）。与此同时，地上的一部分进入了图片中，这是我们不想要的，并且一些logo也是这样。我们需要删除它们。在那里，我们给出一些值为0的像素（确定的背景）。所以我们在前面的例子中修改了我们所得到的mask。

我真正做的是，我在绘画应用程序中打开输入图像，并添加另一个图层的图像。在绘画中使用画笔工具，我用白色和不需要的背景（如标志，地面等）在这个新层上标记错过的前景（头发，鞋子，球等）。然后用灰色填充剩余的背景。然后在OpenCV中加载该遮罩图像，编辑原来的遮罩图像，并在新添加的遮罩图像中得到相应的值。检查下面的代码：

```python
# newmask 是一个我手动打好标签的图片
newmask = cv2.imread('newmask.png',0)

# 被标记为白色的部分（确定的前景），将mask改为1
# 被标记为黑色的部分（确定的背景），将mask改为0
mask[newmask == 0] = 0
mask[newmask == 255] = 1

mask, bgdModel, fgdModel = cv2.grabCut(img,mask,None,bgdModel,fgdModel,5,cv2.GC_INIT_WITH_MASK)

mask = np.where((mask==2)|(mask==0),0,1).astype('uint8')
img = img*mask[:,:,np.newaxis]
plt.imshow(img),plt.colorbar(),plt.show()
```

看下面的结果：

![image](images/grabcut_mask.jpg)

就是这样了。在这里，如果不想在矩形模式下初始化，你可以直接使用掩码模式。只需用值为2的像素或值为3的像素（可能的背景/前景）标记掩模图像中的矩形区域即可。然后像我们在第二个例子中那样用值为1的像素标记我们的sure_foreground。然后直接使用mask模式的grabCut功能。

## 练习

- OpenCV示例包含一个样例grabcut.py，它是一个使用grabcut的交互式工具。去试试看。另外看一下这个关于如何使用它的[YouTube的视频](http://www.youtube.com/watch?v=kAwxLTDDAwU)。

- 你可以把它做成一个交互式的示例，用鼠标绘制矩形和笔画，创建轨迹栏来调整笔画宽度等。