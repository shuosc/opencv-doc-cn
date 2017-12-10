# 模板匹配{#tutorial_py_template_matching_cn}

## 目标

在这一章中，你将学习

- 使用模板匹配查找图像中的对象
- 你会学会这些函数：`cv2.matchTemplate()`，`cv2.minMaxLoc()`

## 理论基础

模板匹配是一种在较大图像中搜索和查找模板图像位置的方法。 OpenCV为此提供了一个函数`cv2.matchTemplate()`。它只是将模板图​​像滑过输入图像（就像2D卷积那样），并将模板图像和输入图像的一小块进行比较。在OpenCV中实现了几种比较方法。 （您可以查看文档了解更多详情）。它返回一个灰度图像，其中每个像素表示该像素的邻域与模板匹配多少。

如果输入图像的大小(WxH)和模板图像的大小(wxh)，输出图像的大小为（W-w + 1，H-h + 1）。一旦得到结果，就可以使用`cv2.minMaxLoc()`函数来查找最大值/最小值。将其作为矩形的左上角，并将（w，h）作为矩形的宽度和高度。那个矩形就是你模板的区域。

如果您使用cv2.TM_SQDIFF作为比较方法，最小值会给出最佳匹配。

## OpenCV中的模板匹配

在这里，作为一个例子，我们将在照片中搜索梅西的脸。所以我创建了一个模板如下：

![image](images/messi_face.jpg)

我们将尝试所有的比较方法，以便我们可以看到他们的结果如何：

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('messi5.jpg',0)
img2 = img.copy()
template = cv2.imread('template.jpg',0)
w, h = template.shape[::-1]

# 所有6种比较方法的列表
methods = ['cv2.TM_CCOEFF', 'cv2.TM_CCOEFF_NORMED', 'cv2.TM_CCORR', 'cv2.TM_CCORR_NORMED', 'cv2.TM_SQDIFF', 'cv2.TM_SQDIFF_NORMED']

for meth in methods:
    img = img2.copy()
    method = eval(meth)
    
    # 应用模版匹配
    res = cv2.matchTemplate(img,template,method)
    min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(res)
        # 如果方法是 TM_SQDIFF或者TM_SQDIFF_NORMED取最小值
    if method in [cv2.TM_SQDIFF, cv2.TM_SQDIFF_NORMED]:
        top_left = min_loc
    else:
        top_left = max_loc
    bottom_right = (top_left[0] + w, top_left[1] + h)
    
    cv2.rectangle(img,top_left, bottom_right, 255, 2)
    
    plt.subplot(121),plt.imshow(res,cmap = 'gray')
    plt.title('Matching Result'), plt.xticks([]), plt.yticks([])
    plt.subplot(122),plt.imshow(img,cmap = 'gray')
    plt.title('Detected Point'), plt.xticks([]), plt.yticks([])
    plt.suptitle(meth)
    
    plt.show()
```



下面是结果：

- cv2.TM_CCOEFF

  ![image](images/template_ccoeff_1.jpg)



- cv2.TM_CCOEFF_NORMED

  ![image](images/template_ccoeffn_2.jpg)



- cv2.TM_CCORR

  ![image](images/template_ccorr_3.jpg)



- cv2.TM_CCORR_NORMED

  ![image](images/template_ccorrn_4.jpg)



- cv2.TM_SQDIFF

  ![image](images/template_sqdiff_5.jpg)



- cv2.TM_SQDIFF_NORMED

  ![image](images/template_sqdiffn_6.jpg)



你可以看到使用`cv2.TM_CCORR`的结果并不像我们预期的那样好。

## 与多个对象匹配的模板

在之前的章节中，我们搜索了梅西的脸部图像，该图像只出现了一次。假设你正在搜索一个对象的多个实例，`cv2.minMaxLoc()`不会给你所有的位置。在这种情况下，我们将使用阈值。所以在这个例子中，我们将使用着名的游戏“马里奥”的截图，我们将在其中找到硬币。

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img_rgb = cv2.imread('mario.png')
img_gray = cv2.cvtColor(img_rgb, cv2.COLOR_BGR2GRAY)
template = cv2.imread('mario_coin.png',0)
w, h = template.shape[::-1]

res = cv2.matchTemplate(img_gray,template,cv2.TM_CCOEFF_NORMED)
threshold = 0.8
loc = np.where( res >= threshold)
for pt in zip(*loc[::-1]):
    cv2.rectangle(img_rgb, pt, (pt[0] + w, pt[1] + h), (0,0,255), 2)

cv2.imwrite('res.png',img_rgb)
```

结果：

![image](images/res_mario.jpg)

