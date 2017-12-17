# 高动态范围（HDR）{#tutorial_py_hdr_cn}

## 目标

在这一章中，我们会

- 了解如何从曝光序列生成并显示HDR图像。
- 使用曝光融合合并曝光序列。

##理论基础

高动态范围成像（HDRI或HDR）是一种用于成像和摄影的技术，以再现比标准数字成像或照相技术更大的亮度动态范围。虽然人眼可以适应广泛的光线条件，但大多数成像设备每个通道使用8位，因此我们只能将其限制在256级。当我们拍摄现实世界的照片时，明亮的区域可能会曝光过度，而黑暗的区域可能曝光不足，所以我们无法使用一次曝光捕捉所有细节。 HDR成像适用于每通道使用超过8位（通常为32位浮点值）的图像，从而允许更宽的动态范围。

获取HDR图像有不同的方法，但最常见的方法是使用不同曝光值拍摄的场景的照片。要结合这曝光的结果，了解您的相机的响应函数是有用的，有一些算法来估计它。 HDR图像合并之后，必须将其转换回8位才能在通常的显示器上查看。这个过程被称为色调映射。当场景或相机的物体在两次拍摄之间移动时，会产生更多的复杂性，因为具有不同曝光的图像应该被记录和对齐。

在本教程中，我们将展示2种算法（Debvec，Robertson），用于从曝光序列生成并显示HDR图像，并演示一种称为曝光融合（Mertens）的替代方法，可生成低动态范围图像，而不需要曝光时间数据。

此外，我们估计了相机响应函数（CRF），这对于许多计算机视觉算法来说是非常有价值的。

HDR流水线的每一步都可以使用不同的算法和参数来实现，所以请看看参考手册来了解所有这些算法和参数。

## 曝光顺序HDR

在本教程中，我们将看到下面的图片，我们有4个曝光图像，曝光时间为：15, 2.5, 1/4 和 1/30 秒。 （您可以从[维基百科](https://en.wikipedia.org/wiki/High-dynamic-range_imaging)下载图片）

###1. 将曝光图像加载到列表中

第一阶段只是将所有图像加载到列表中。另外，我们需要常规HDR算法的曝光时间。请注意数据类型，因为图像应该是1通道或3通道8位（np.uint8），曝光时间需要为float32，以秒为单位。

```python
import cv2
import numpy as np

# 将曝光过的图像加载到列表
img_fn = ["img0.jpg", "img1.jpg", "img2.jpg", "img3.jpg"]
img_list = [cv2.imread(fn) for fn in img_fn]
exposure_times = np.array([15.0, 2.5, 0.25, 0.0333], dtype=np.float32)
```

###2. 合并曝光到HDR图像

在这个阶段，我们将曝光序列合并成一个HDR图像，显示了我们在OpenCV中的两种可能性。第一种方法是Debvec，第二种是Robertson。请注意，HDR图像的类型是float32，而不是uint8，因为它包含所有曝光图像的全部动态范围。

```python
# 将曝光合并到HDR图像
merge_debvec = cv2.createMergeDebevec()
hdr_debvec = merge_debvec.process(img_list, times=exposure_times.copy())
merge_robertson = cv2.createMergeRobertson()
hdr_robertson = merge_robertson.process(img_list, times=exposure_times.copy())
```

###3. HDR图像的色调映射

我们将32位浮点型HDR数据映射到[0..1]范围内。

实际上，在某些情况下，值可能大于1或者低于0，所以注意我们稍后必须剪切数据以避免溢出。

```python
# HDR图像的色调映射
tonemap1 = cv2.createTonemapDurand(gamma=2.2)
res_debvec = tonemap1.process(hdr_debvec.copy())
tonemap2 = cv2.createTonemapDurand(gamma=1.3)
res_robertson = tonemap2.process(hdr_robertson.copy())
```

### 4. 使用Mertens融合合并曝光

在这里，我们展示了一个合并曝光图像的替代算法，我们不需要曝光时间。我们也不需要使用任何色调映射算法，因为Mertens算法已经在[0..1]范围内给出结果。

```python
# 使用Mertens融合合并曝光
merge_mertens = cv2.createMergeMertens()
res_mertens = merge_mertens.process(img_list)
```

### 5. 转换为8位并保存

为了保存或显示结果，我们需要将数据转换为在[0..255]的范围内8位整数。

```python
# 转换为8位整数并储存
res_debvec_8bit = np.clip(res_debvec*255, 0, 255).astype('uint8')
res_robertson_8bit = np.clip(res_robertson*255, 0, 255).astype('uint8')
res_mertens_8bit = np.clip(res_mertens*255, 0, 255).astype('uint8')

cv2.imwrite("ldr_debvec.jpg", res_debvec_8bit)
cv2.imwrite("ldr_robertson.jpg", res_robertson_8bit)
cv2.imwrite("fusion_mertens.jpg", res_mertens_8bit)
```

## 结果

你可以看到不同的结果，但记住每个算法都有额外的参数，你应该尝试不同方法来得到你想要的结果。最好的做法是尝试不同的方法，看看哪一个最适合你的场景。

###Debvec:

![image](images/ldr_debvec.jpg)

### Robertson:

![image](images/ldr_robertson.jpg)

### Mertenes 融合:

![image](images/fusion_mertens.jpg)

##估计相机响应函数

相机响应函数（CRF）使我们能够将场景辐射与测量的强度值连接起来。 CRF在一些计算机视觉算法中非常重要，包括HDR算法。在这里，我们估计反向相机响应函数，并将其用于HDR合并。

```python
# 估计相机响应函数 (CRF)
cal_debvec = cv2.createCalibrateDebevec()
crf_debvec = cal_debvec.process(img_list, times=exposure_times)
hdr_debvec = merge_debvec.process(img_list, times=exposure_times.copy(), response=crf_debvec.copy())
cal_robertson = cv2.createCalibrateRobertson()
crf_robertson = cal_robertson.process(img_list, times=exposure_times)
hdr_robertson = merge_robertson.process(img_list, times=exposure_times.copy(), response=crf_robertson.copy())
```

相机响应函数由每个颜色通道的256长度矢量表示。对于这个序列，我们得到了以下的估计：

![image](images/crf.jpg)

## 更多资源

1. Paul E Debevec and Jitendra Malik. Recovering high dynamic range radiance maps from photographs. In ACM SIGGRAPH 2008 classes, page 31. ACM, 2008.
2. Mark A Robertson, Sean Borman, and Robert L Stevenson. Dynamic range improvement through multiple exposures. In Image Processing, 1999. ICIP 99. Proceedings. 1999 International Conference on, volume 3, pages 159–163. IEEE, 1999.
3. Tom Mertens, Jan Kautz, and Frank Van Reeth. Exposure fusion. In Computer Graphics and Applications, 2007. PG'07. 15th Pacific Conference on, pages 382–390. IEEE, 2007.
4. 图片来自[维基百科-HDR](https://zh.wikipedia.org/wiki/高动态范围成像)

## 练习

1. 尝试所有的色调映射算法：Drago，Durand，Mantiuk和Reinhard。
2. 尝试更改HDR校准和色调映射函数中的参数。