# 傅立叶变换{#tutorial_py_fourier_transform_cn}

## 目标

在这一节中，我们将学习

- 使用OpenCV查找图像的傅立叶变换
- 利用Numpy中的FFT功能
- 傅立叶变换的一些应用
- 我们将学到以下函数：`cv2.dft()`，`cv2.idft()`等

理论

傅立叶变换用于分析各种滤波器的频率特性。对于图像，可以使用2D离散傅里叶变换（DFT）来查找频域。被称为快速傅立叶变换（FFT）的快速算法被用于DFT的计算。有关这些的细节可以在任何图像处理或信号处理的教科书中找到。请参阅更多资源部分。

对于一个正弦信号$x(t) = A \sin(2 \pi ft)$，我们可以说$f$是信号的频率，如果它的频域被采用，我们可以在$f$处看到一个尖峰。如果信号被采样形成一个离散信号，我们会得到相同的频域，但是在$[ -\pi,\pi]$或者$[0,2\pi]$（或者$[0,N]$，如果进行的是N-point DFT）有周期性。您可以将图像视为在两个方向上采样的信号。因此，在X和Y方向上进行傅里叶变换将给出图像的频率表示。

更直观地说，对于正弦信号，如果幅度在短时间内变化快，那么可以说它是一个高频信号。如果变化缓慢，则是低频信号。您可以将相同的想法扩展到图像。图像中哪些部分振幅的变化幅度大？在边缘点，或是噪音部分。所以可以说，边缘和噪声是图像中的高频内容。如果振幅没有太大的变化，则是低频部分。 （更多资源部分有一些链接，这些资源通过例子直观地解释频率转换）。

现在我们将看到如何找到傅里叶变换。

## Numpy中的傅里叶变换

首先，我们将看到如何使用Numpy来查找傅立叶变换。 Numpy有一个FFT包来做到这一点。 `np.fft.fft2()`为我们提供了频率变换，这将是一个复杂的数组。它的第一个参数是灰度格式的输入图像。第二个参数是可选的，它决定了输出数组的大小。如果大于输入图像的大小，则在计算FFT之前，输入图像用零填充。如果小于输入图像，输入图像将被裁剪。如果没有参数传递，输出数组大小将与输入相同。

现在一旦得到结果，零频率分量（DC分量）将位于左上角。如果要将它置于中间，则需要在两个方向上将结果移动$\frac {N} {2}$。这只需要调用函数`np.fft.fftshift()`就能完成。 （这样更容易分析）。一旦你找到频率变换，你也可以找到幅度谱。

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('messi5.jpg',0)
f = np.fft.fft2(img)
fshift = np.fft.fftshift(f)
magnitude_spectrum = 20*np.log(np.abs(fshift))
plt.subplot(121),plt.imshow(img, cmap = 'gray')
plt.title('Input Image'), plt.xticks([]), plt.yticks([])
plt.subplot(122),plt.imshow(magnitude_spectrum, cmap = 'gray')
plt.title('Magnitude Spectrum'), plt.xticks([]), plt.yticks([])
plt.show()
```



结果如下所示：

![image](images/fft1.jpg)

看，你可以在中心看到更多白色的区域，这显示出低频内容更多。

所以你找到了频率变换，现在你可以在频域做一些操作，如高通滤波和重构图像，即找到逆DFT。为此，您只需通过使用尺寸为60x60的矩形窗口进行mask来消除低频。然后使用np.fft.ifftshift（）应用反转，使DC分量再次出现在左上角。然后使用np.ifft2*(函数找到反FFT。结果也是一个复杂的数字。你可以取它的绝对值。

```python
rows, cols = img.shape
crow,ccol = rows/2 , cols/2
fshift[crow-30:crow+30, ccol-30:ccol+30] = 0
f_ishift = np.fft.ifftshift(fshift)
img_back = np.fft.ifft2(f_ishift)
img_back = np.abs(img_back)
plt.subplot(131),plt.imshow(img, cmap = 'gray')
plt.title('Input Image'), plt.xticks([]), plt.yticks([])
plt.subplot(132),plt.imshow(img_back, cmap = 'gray')
plt.title('Image after HPF'), plt.xticks([]), plt.yticks([])
plt.subplot(133),plt.imshow(img_back)
plt.title('Result in JET'), plt.xticks([]), plt.yticks([])
plt.show()
```



结果如下所示：

![image](images/fft2.jpg)

结果显示高通滤波是一个边缘检测操作。这就是我们在“图像梯度”一章中看到的。这也表明大部分图像数据存在于频谱的低频区域中。无论如何，我们已经看到如何在Numpy中找到DFT，IDFT等。现在让我们看看如何在OpenCV中完成它。

如果仔细观察结果，尤其是JET颜色中的最后一个图像，则可以看到一些artifacts（我用红色箭头标记了一个实例）。它在那里显示出一些波纹状的结构，这被称为 **ringing effects**。这是由我们用于mask的矩形窗口引起的。这个mask被转换成正弦形状，从而导致了这个问题。所以矩形窗口不适用于过滤。更好的选择是高斯窗口。

## OpenCV中的傅立叶变换

OpenCV为此提供了函数`cv2.dft()`和`cv2.idft()`。它返回与前面相同的结果，但有两个通道。第一个通道包含结果的实部，第二个通道包含结果的虚部。输入图像应先转换为`np.float32`。我们将看到如何做到这一点。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt

img = cv2.imread('messi5.jpg',0)
dft = cv2.dft(np.float32(img),flags = cv2.DFT_COMPLEX_OUTPUT)
dft_shift = np.fft.fftshift(dft)
magnitude_spectrum = 20*np.log(cv2.magnitude(dft_shift[:,:,0],dft_shift[:,:,1]))
plt.subplot(121),plt.imshow(img, cmap = 'gray')
plt.title('Input Image'), plt.xticks([]), plt.yticks([])
plt.subplot(122),plt.imshow(magnitude_spectrum, cmap = 'gray')
plt.title('Magnitude Spectrum'), plt.xticks([]), plt.yticks([])
plt.show()
```

所以，现在我们必须做逆DFT。在之前的教程中，我们创建了一个高通过滤器，这次我们将看到如何去除图像中的高频内容，即将低通过滤器应用于图像。它实际上模糊了图像。为此，我们首先在低频处创建一个高值（1）的掩模，即我们让低频内容通过，并在高频区域传递0。

```python
rows, cols = img.shape
crow,ccol = rows/2 , cols/2

# 先创造一个mask，中间的方块是1，其他全是0
mask = np.zeros((rows,cols,2),np.uint8)
mask[crow-30:crow+30, ccol-30:ccol+30] = 1

# 使用mask并进行反向DFT
fshift = dft_shift*mask
f_ishift = np.fft.ifftshift(fshift)
img_back = cv2.idft(f_ishift)
img_back = cv2.magnitude(img_back[:,:,0],img_back[:,:,1])

plt.subplot(121),plt.imshow(img, cmap = 'gray')
plt.title('Input Image'), plt.xticks([]), plt.yticks([])
plt.subplot(122),plt.imshow(img_back, cmap = 'gray')
plt.title('Magnitude Spectrum'), plt.xticks([]), plt.yticks([])
plt.show()
```

下面是结果：

![image](images/fft4.jpg)

像往常一样，OpenCV函数`cv2.dft()`和`cv2.idft()`比Numpy中的等价的函数更快。但是Numpy函数更加用户友好。有关性能问题的更多细节，请参阅下面的部分。

## DFT的性能优化

DFT计算性能对于某些数组大小来说会更好。当数组大小是2的幂时，它是最快的。大小为2，3，和5的乘积的数组也被相当有效地处理。所以如果你担心你的代码的性能，您可以在查找DFT之前将数组大小修改为任何最佳大小（通过填充零）。对于OpenCV，您必须手动填充零。但是对于Numpy来说，你可以指定FFT计算的新大小，它会自动为你填充零。

这个性能优化方法适用于`cv2.dft()`和`np.fft.fft2()`。让我们使用IPython魔术命令`％timeit`来检查它们的性能。

```python
In [16]: img = cv2.imread('messi5.jpg',0)
In [17]: rows,cols = img.shape
In [18]: print("{} {}".format(rows,cols))
342 548

In [19]: nrows = cv2.getOptimalDFTSize(rows)
In [20]: ncols = cv2.getOptimalDFTSize(cols)
In [21]: print("{} {}".format(nrows,ncols))
360 576
```

看，大小（342,548）被修改为（360,576）。 现在让我们填充零（对于OpenCV），并观察他们的DFT计算性能。 你可以通过创建一个全零数组并将数据复制到它里面，或使用`cv2.copyMakeBorder()`。

```python
nimg = np.zeros((nrows,ncols))
nimg[:rows,:cols] = img
```

或是

```python
right = ncols - cols
bottom = nrows - rows
bordertype = cv2.BORDER_CONSTANT # 只是为了避免PDF文件中的换行
nimg = cv2.copyMakeBorder(img,0,bottom,0,right,bordertype, value = 0)
```

现在我们计算一下Numpy函数的DFT性能比较：

```python
In [22]: %timeit fft1 = np.fft.fft2(img)
10 loops, best of 3: 40.9 ms per loop
In [23]: %timeit fft2 = np.fft.fft2(img,[nrows,ncols])
100 loops, best of 3: 10.4 ms per loop
```

它显示了一个4倍的加速。现在我们将尝试使用OpenCV函数。

```python
In [24]: %timeit dft1= cv2.dft(np.float32(img),flags=cv2.DFT_COMPLEX_OUTPUT)
100 loops, best of 3: 13.5 ms per loop
In [27]: %timeit dft2= cv2.dft(np.float32(nimg),flags=cv2.DFT_COMPLEX_OUTPUT)
100 loops, best of 3: 3.11 ms per loop
```

它也显示了4倍的加速。 你也可以看到OpenCV的功能比Numpy功能快3倍左右。 这也可以在逆FFT上测试，这是留给你一个练习。

## 为什么拉普拉斯是高通滤波器？

一个类似的问题常常在论坛上被问到。 为什么拉普拉斯是一个高通滤波器？ 为什么Sobel滤波器是高通滤波器？ 等等。第一个答案是傅立叶变换中的术语。 只要对拉普拉斯算子进行傅立叶变换，就可以得到更高的FFT。 分析：

```python
import cv2
import numpy as np
from matplotlib import pyplot as plt

# 简单平均滤波器内核
mean_filter = np.ones((3,3))

# 高斯滤波器
x = cv2.getGaussianKernel(5,10)
gaussian = x*x.T

# 不同的边缘检测滤波器
# x方向上的scharr
scharr = np.array([[-3, 0, 3],
                   [-10,0,10],
                   [-3, 0, 3]])
# x方向上的sobel
sobel_x= np.array([[-1, 0, 1],
                   [-2, 0, 2],
                   [-1, 0, 1]])
# y方向上的sobel
sobel_y= np.array([[-1,-2,-1],
                   [0, 0, 0],
                   [1, 2, 1]])
# 拉普拉斯
laplacian=np.array([[0, 1, 0],
                    [1,-4, 1],
                    [0, 1, 0]])

filters = [mean_filter, gaussian, laplacian, sobel_x, sobel_y, scharr]
filter_name = ['mean_filter', 'gaussian','laplacian', 'sobel_x', 'sobel_y', 'scharr_x']
fft_filters = [np.fft.fft2(x) for x in filters]
fft_shift = [np.fft.fftshift(y) for y in fft_filters]
mag_spectrum = [np.log(np.abs(z)+1) for z in fft_shift]

for i in xrange(6):
    plt.subplot(2,3,i+1),plt.imshow(mag_spectrum[i],cmap = 'gray')
    plt.title(filter_name[i]), plt.xticks([]), plt.yticks([])

plt.show()
```

![image](images/fft5.jpg)

从图像中，可以看到每个内核阻塞的频率范围，以及它不阻塞的区域。 从这些信息中，我们可以说为什么一个个内核是高通或低通滤波器。

## 更多资源

- [傅立叶理论的一个直观解释](http://cns-alumni.bu.edu/~slehar/fourier/fourier.html) by Steven Lehar
- [傅立叶变换](http://homepages.inf.ed.ac.uk/rbf/HIPR2/fourier.htm) at HIPR
- [频域在图像中表示什么？](http://dsp.stackexchange.com/q/1637/818)