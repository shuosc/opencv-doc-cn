# 使用SVM的手写数据的OCR {#tutorial_py_svm_opencv_cn}

##目标

在这一章当中

- 我们将重新审视手写数据OCR，但用SVM代替kNN。

##手写数字OCR

在kNN中，我们直接使用像素强度作为特征向量。这次我们将使用面向梯度直方图（HOG）作为特征向量。

在这里，在找到HOG之前，我们使用它的二阶矩来歪斜图像。所以我们首先定义一个函数`deskew()`，他接受一个数字图像并对其进行歪斜。下面是deskew()函数：

@snippet samples/python/tutorial_code/ml/py_svm_opencv/hogsvm.py deskew

下图显示了上面的deskew函数作用于零图像。左图是原始图像，右图是去歪斜的图像。

![image](images/deskew.jpg)

接下来我们必须找到每个单元格的HOG描述符。为此，我们在X和Y方向上找到每个单元的Sobel导数。然后在每个像素处找到它们的梯度大小和方向。这个梯度量化为16个整数值。将此图像分为四个子方块。对于每个子方块，计算以其大小加权的方向（16个bin）的直方图。每个子方块给你一个包含16个值的矢量。四个这样的矢量（四个子方块）一起给了我们一个包含64个值的特征向量。这是我们用来训练数据的特征向量。

@snippet samples/python/tutorial_code/ml/py_svm_opencv/hogsvm.py hog

最后，和前面的例子一样，我们首先将我们的大数据集分解成单独的单元格。对于每个数字，保留250个单元用于训练数据，剩下的250个数据被保留用于测试。完整的代码如下，你也可以从这里下载：

@include samples/python/tutorial_code/ml/py_svm_opencv/hogsvm.py

这个技术给了我近94％的准确性。您可以尝试使用不同的SVM参数值来检查是否有更高的准确性。或者你可以阅读这方面的技术文件，并尝试实施它们。

## 其他资源

- [定向梯度视频的直方图](www.youtube.com/watch?v=0Zib1YEE4LU‎)

## 练习

- OpenCV示例包含了digits.py，它对上述方法稍加改进，以获得更好的结果。它也包含参考。查看并理解它。