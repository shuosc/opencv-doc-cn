使用 Haar Cascades 的面部识别{#tutorial_py_face_detection_cn}
==================================

目标
----

在这个部分,

-   我们会学习基于 Haar 特征的级联分类器（Haar Feature-based Cascade Classifiers）来进行简单的面部识别 
-   我们还会将这些拓展至眼部识别等其他目标检测中

基础
------

基于 Haar 特征的级联分类器（Haar Feature-based Cascade Classifiers）是一种十分高效的目标检测技术。
这一方法最早由 Paul Viola 和 Michael Jones 于2001年在他们的论文中提出。这种基于机器学习的方法使用大量的正负样本来训练并最终得到一个cascade
function，用于最终的目标检测工作 

我们现在开始学习面部检测。岁开始，算法需要很多正样本（含有面部的图像）以及许多负样本（不含面部的图像）来训练选择器。然后我们需要从中提取特征。为此，我们将用到下图的Haar特征。他们就像我们的卷积核。每一个特征都代表区域内黑色矩形下的像素值之和减去白色矩形下的像素值之和 

![image](images/haar_features.jpg)

现在，我们使用了一切可能的核的大小和位置来计算特征（但稍微想想这个计算量会有多大，即使是一个 24 X 24 的区域也会出现 160000 个特征）。对于每一个特征值计算我们都需要分别算出黑色与白色矩形下的像素之和。为了解决这个问题，我们引入了积分图像的概念。它可以大大地简化对于像素点的求和计算，对于任何一个区域的像素和只需要对积分 图像上的四个像素操作即可。这样运算快的飞起。 

但我们计算的大多数特征都是互不相关的。以下图为例。最上面一行显示了两个效果比较好的特征。第一个特征看上去是对眼部周围区域的描 述,因为眼睛总是比鼻子黑一些。第二个特征是描述的是眼睛比鼻梁要黑一些。但如果同样的窗口放到脸颊的话就非常的不合适了，那么我们怎样从超过 160000+ 个特征中选出最好的特征呢?使用
**Adaboost**.

![image](images/haar.png)

为了达到这个目的，我们将每个特征应用于所有训练集中的图片。对于每一个特征，寻找出能分清楚正负样本的最佳阈值。但很显然这回存在错误以及误分类。我们需要选取错误率最低的特征，换言之也就是进行面部检测效果最好的特征（整个过程当然没有这么简单。每一个图像在最开始都有相同的权重。在几次分类之后，误分类图像的权重会增大。然后再做一次分类，这样我们就得到了新的错误率与权重。重复这一过程，直到达到要求的准确率或是错误率，亦或者找到了指定数量的特征）

最后的分类器就是这些弱分类器的加权之和。之所以称为“弱分类器”是因为它不能独立分类一个图像，但同其它分类器一同可以达到一个很强的效果。论文中说200 个特征就能够提供 95% 的准确度了。他们最 后使用了 6000 个特征。(从 160000 减到 6000,效果很好呀)

现在你有一幅图像。对于每一个 24x24 的窗口都实用这 6000 个特征去检查是否有面部。是不是感觉非常的耗时呢？作者有一个解决问题的好办法。

在一个图像中，大多数区域是没有面部的。所以用一个简单的方法来快速检测这个窗口不是面部区域，,如果不是就直接抛弃,不用对它再做处理。转而专注于研究疑似面部的区域。按照这种方法我们可以在可能是面部的区域多花点时间。

为了达到这个目的，作者提出了**级联分类器**的概念。不在一开始就将这 6000 个特征作用于每个窗口,而是将这些特征分成不同组。在不同的分类下再逐个使用。（通常最开始的几个组都只会包含很少的特征）如果一个窗口第一阶段的检测都过不了就可以直接放弃后面的测试了,如果通过了就进入第二阶段的检测。经过了所有测试的被认为是面部区域，是不是很强(￣∇￣)

作者将 6000 多个特征分为 38 个阶段,前五个阶段的特征数分别为 1,10,25,25 和 50。(上图中的两个特征其实就是从 Adaboost 获得的最好特征)。按作者的话说，平均来看对于每个图像来说只用到了 6000 多个特征中的十个。 

这就是我们对于Viola-Jones面部识别技术如何工作的一些简单解释。读一下原始论文或者更多资源中非参考文献将会对你有更大帮助。

OpenCV 中的 Haar 级联检测
--------------------------------

OpenCV 自带了训练器和检测器。如果你想自己训练一个分类器来检测汽车,飞机等的话,可以使用 OpenCV 构建。其中的细节在这里:
[Cascade Classifier Training](@ref tutorial_traincascade).

现在我们来学习一下如何使用检测器。OpenCV 已经包含了很多已经训练好的分类器,其中包括:面部,眼睛,微笑等。这些 XML 文件保存在/opencv/ data/haarcascades/文件夹中。下面我们将使用 OpenCV 创建一个面部和眼部检测器。

首先我们要加载需要的 XML 分类器。然后以灰度模式加载输入图像或者是视频。
@code{.py}
import numpy as np
import cv2

face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
eye_cascade = cv2.CascadeClassifier('haarcascade_eye.xml')

img = cv2.imread('sachin.jpg')
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
@endcode
现在我们在图像中检测面部。如果检测到面部,它会返回面部所在的矩形区域 Rect(x,y,w,h)。一旦我们获得这个位置,我们可以创建一个 ROI 并在其中进行眼部检测。(谁让眼睛长在脸上呢／摊手)
@code{.py}
faces = face_cascade.detectMultiScale(gray, 1.3, 5)
for (x,y,w,h) in faces:
    cv2.rectangle(img,(x,y),(x+w,y+h),(255,0,0),2)
    roi_gray = gray[y:y+h, x:x+w]
    roi_color = img[y:y+h, x:x+w]
    eyes = eye_cascade.detectMultiScale(roi_gray)
    for (ex,ey,ew,eh) in eyes:
        cv2.rectangle(roi_color,(ex,ey),(ex+ew,ey+eh),(0,255,0),2)

cv2.imshow('img',img)
cv2.waitKey(0)
cv2.destroyAllWindows()
@endcode
结果如下：

![image](images/face.jpg)

更多资源
--------------------

-#  Video Lecture on [Face Detection and Tracking](http://www.youtube.com/watch?v=WfdYYNamHZ8)
2.  An interesting interview regarding Face Detection by [Adam
    Harvey](http://www.makematics.com/research/viola-jones/)

Exercises
---------
