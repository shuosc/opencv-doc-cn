# Shi-Tomasi 角点检测 & 适合用来跟踪的特征{#tutorial_py_shi_tomasi_cn}

## 目标

在这一章中：

- 我们将会学习另外一个角点检测器：Shi-Tomasi 角点检测器。
- 我们会看到函数：`cv2.goodFeaturesToTrack()`的使用方法。

## 理论基础

上一章中，我们看到了Harris角点检测器。在1994年晚些时候， J. Shi 和 C. Tomasi在它们的论文《Good Features to Track》[^1]对其进行了一个小小的改动来产生更佳的效果。

Harris角点检测器的评分函数是这样的：
$$
R = \lambda_1 \lambda_2 - k(\lambda_1+\lambda_2)^2
$$
与此不同的是，Shi-Tomasi使用：
$$
R = min(\lambda_1, \lambda_2)
$$
如果这里的$R$比一个特定的阈值大，那么这个点就是一个角点。如果我们像在Harris角点检测器中做的那样将其在$\lambda_1 - \lambda_2$平面内画出来，我们将得到这样的图像：

![image](images/shitomasi_space.png)

从图像中，你可以看出只有当$\lambda_1$和$\lambda_2$都比一个最小值$\lambda_{min}$大的时候，这个点才会被当作是一个角点（即位于图中的绿区）。

## 代码

OpenCV有一个函数`cv2.goodFeaturesToTrack()`。 它用Shi-Tomasi方法（或Harris角点检测，如果手动指定的话）在图像中找到N个最强的角点。 像往常一样，图像应该是一个灰度图像。 然后你需要指定需要的角点的数量。 然后你要指定质量等级，这是一个介于0-1之间的值，每个质量小于这个值的焦点都会被丢弃。 然后要提供检测到的角点之间的最小欧几里得距离。

利用所有这些信息，该函数在图像中找到角点。 质量水平以下的所有角点都被丢弃。 然后对剩余的角点根据质量按降序排列。

然后函数取第一个最强的角点，将距离范围内的所有附近的角点丢弃，并返回N个最强的点。

在下面的例子中，我们将尝试找到25个最好的角点：

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt

img = cv2.imread('blox.jpg')
gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
corners = cv2.goodFeaturesToTrack(gray,25,0.01,10)
corners = np.int0(corners)
for i in corners:
    x,y = i.ravel()
    cv2.circle(img,(x,y),3,255,-1)
plt.imshow(img)
plt.show()
```

结果如下：

![image](images/shitomasi_block1.jpg)

这个函数更适合用于跟踪。当时机到来时我们将看到这一点。

[^1]: http://citeseer.ist.psu.edu/shi94good.html 

