特征检测和描述符 {#tutorial_py_table_of_contents_feature2d}
=================================

-   @subpage tutorial_py_features_meaning

    图像中的主要特征是什么？如果找出对我们来说有用的特征？

-   @subpage tutorial_py_features_harris

    好吧, 边角是好的特征。但我们该如何找到它们呢？ 

-   @subpage tutorial_py_shi_tomasi

    我们将会研究Shi-Tomasi角点检测。

-   @subpage tutorial_py_sift_intro

    当图像的大小变化时，Harris角点检测不够好。Lowe发现了一个突破性的方法来发现尺度不变的特征，这个方法称为SIFT。

-   @subpage tutorial_py_surf_intro

    SIFT真的很好用，但它不够快，所以人们想出了一个更快速的版本叫SURF。

-   @subpage tutorial_py_fast

    所有上面这些特征检测的方法都很好。但是对于像SLAM这样的实时应用程序来说它们都不够快。所以就有了FAST算法，它真的很“FAST”。

-   @subpage tutorial_py_brief

    SIFT使用了一个包含128个浮点数的特征描述符。

    考虑到可能会有数千个这样的特征，它将会花费许多内存和很多事件来进行特征匹配。

    我们可以“压缩”它来使它变得更快，但我们还是要首先计算它。

    BRIEF算法可以让我我们快捷地找到二进制描述符，同时使用更少的内存、更少的匹配时间，同时也不损失识别率。

-   @subpage tutorial_py_orb

    SIFT 和 SURF在其各自的作用领域都很好，但他们是有专利保护的算法，如果你不想为在你的应用程序中使用这样的算法付钱怎么办？ 为了解决这个问题，OpenCV开发者们想到了一个SIFT和SURF的免费替代品，这就是ORB。

-   @subpage tutorial_py_matcher

    我们现在知道了很多特征检测器和描述符。现在是时候来学习如何匹配不同的描述符了。OpenCV提供了两个用来做这件事的技术，蛮力匹配和FLANN匹配。

-   @subpage tutorial_py_feature_homography

    我们现在会特征匹配了，让我们将之与calib3模块结合来在一个复杂图片中寻找物体。

