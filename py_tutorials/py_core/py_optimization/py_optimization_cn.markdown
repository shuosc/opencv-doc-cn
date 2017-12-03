# 性能评估和改进技巧{#tutorial_py_optimization_cn}

## 目标

在图像处理中，由于您每秒需要处理大量的操作，所以您的代码不仅要提供正确的解决方案，还要以最快的方式进行处理。

所以在这一章中，你将学习

- 测量你的代码的性能。
- 一些提高你的代码性能的提示。
- 你会学到这些函数：`cv2.getTickCount`，`cv2.getTickFrequency`等

除了OpenCV之外，Python还提供了一个有助于测量执行时间的模块`time`。另一个模块`profile`有助于获得有关代码的详细报告，例如代码中每个函数占用了多少时间，函数被调用了多少次等。但是，如果使用IPython，则所有这些功能都以用户友好的方式集成起来了。我们会看到其中一些重要的功能，有关更多详细信息，请查看**附加资源**部分中的链接。

## 用OpenCV测量性能

`cv2.getTickCount`函数返回一个参考事件（就像机器开启的瞬间），到此函数被调用之间的时钟周期数。所以如果你在一个函数执行之前和之后调用它，你会得到用来执行一个函数的时钟周期数。

`cv2.getTickFrequency`函数返回时钟周期的频率或每秒钟的时钟周期数。所以要以秒数为单位测量执行的时间，你可以这样做：

```python
e1 = cv2.getTickCount()
# 你的代码
e2 = cv2.getTickCount()
time = (e2 - e1)/ cv2.getTickFrequency()
```

我们将用下面的例子来演示。下面的例子运行内核大小为从5到49的奇数的中值滤波（不用担心这做的到底都是些啥，这不是我们的目标）：

```python
img1 = cv2.imread('messi5.jpg')
e1 = cv2.getTickCount()
for i in xrange(5,49,2):
    img1 = cv2.medianBlur(img1,i)
e2 = cv2.getTickCount()
t = (e2 - e1)/cv2.getTickFrequency()
print(t)
# 我得到的结果是0.521107655秒
```

你可以使用`time`模块进行相同的操作。使用`time.time()`函数而不是`cv2.getTickCount`。然后取两次时间的差值。

## OpenCV中的默认优化

许多OpenCV函数默认都使用SSE2，AVX等进行了优化。但OpenCV源码中还包含这些函数的未优化版本。

所以如果我们的系统支持这些功能，我们应该利用它们（几乎所有的现代处理器都支持它们）。编译时默认启用这些功能。如果它被启用，OpenCV会运行优化的代码，否则它会运行未优化的代码。您可以使用`cv2.useOptimized()`来检查它是否被启用/禁用，并使用`cv2.setUseOptimized()`来启用/禁用它。我们来看一个简单的例子。

```python
In [5]: cv2.useOptimized()
Out[5]: True

In [6]: %timeit res = cv2.medianBlur(img,49)
10 loops, best of 3: 34.9 ms per loop

# 禁用它
In [7]: cv2.setUseOptimized(False)

In [8]: cv2.useOptimized()
Out[8]: False

In [9]: %timeit res = cv2.medianBlur(img,49)
10 loops, best of 3: 64.1 ms per loop
```

看，优化的中值滤波比未优化的版本大约快两倍。如果你看看源代码，你可以看到中值滤波是SIMD优化的。所以你可以在代码顶部启用它的优化（记得它是默认启用的）。

## 使用IPython测量性能

有时您可能需要比较两个类似操作的性能。 IPython给你一个魔术命令％timeit来执行此操作。它多次运行代码以获得更准确的结果。

这适合测量单行代码。

例如，你是否知道下面哪个加法操作更好

```python
x = 5; y = x**2
```

```python
x = 5; y = x*x
```

```python
x = np.uint8([5]); y = x*x
```

还是

```python
x = np.uint8([5]); y = np.square(x)
```

？我们会在IPython shell中用％timeit找到答案。

```python
In [10]: x = 5

In [11]: %timeit y=x**2
10000000 loops, best of 3: 73 ns per loop

In [12]: %timeit y=x*x
10000000 loops, best of 3: 58.3 ns per loop

In [15]: z = np.uint8([5])

In [17]: %timeit y=z*z
1000000 loops, best of 3: 1.25 us per loop

In [19]: %timeit y=np.square(z)
1000000 loops, best of 3: 1.16 us per loop
```

你可以看到，

```python
x = 5; y = x * x
```

是最快的，比Numpy快20倍左右。如果你考虑创建数组的时间，这个数值可能会达到100倍。很酷，对吧？ （Numpy开发者正在研究这个问题）

Python标量操作比Numpy标量操作更快。所以对于包含一个或两个元素的操作，Python标量比Numpy数组要好。当数组的大小稍微大点时，Numpy会占据优势。

我们将再尝试一个例子。这一次，我们将比较同一图像的`cv2.countNonZero()`和`np.count_nonzero()`的性能。

```python
In [35]: %timeit z = cv2.countNonZero(img)
100000 loops, best of 3: 15.8 us per loop

In [36]: %timeit z = np.count_nonzero(img)
```

看，OpenCV函数比Numpy函数快近25倍。

通常，OpenCV函数比Numpy函数更快。所以对于相同的操作，OpenCV函数应当是首选。但是，可能会有例外，尤其是当Numpy使用视图而不是副本时。

## 更多的IPython魔术命令

有几个其他的魔术命令来测量性能，逐行分析，测量内存用量等，他们都有很好的文档。所以这里只提供那些文档的链接。有兴趣的读者可以尝试一下。

## 性能优化技术

有几种技术和编码方法来利用Python和Numpy的最大性能。

这里只注明相关内容，并给出其来源的链接。这里要注意的很重要的一点就是，首先尝试以简单的方式实现算法。一旦它工作正常，分析它，找到瓶颈并优化它们。

1. 尽可能避免在Python中使用循环，特别是双/三重循环等。它们注定很慢。
2. 尽量矢量化算法/代码，因为Numpy和OpenCV针对矢量操作进行了优化。
3. 利用缓存一致性。
4. 除非必要，否则不要复制数组。尝试使用视图。数组复制是一个代价高昂的操作。

在完成所有这些操作之后，如果代码仍然很慢，或者使用循环是不可避免的，那么可以使用像Cython这样的其他库来加快速度。

## 更多资源

1.  [Python优化技术](http://wiki.python.org/moin/PythonSpeed/PerformanceTips)
2. Scipy Lecture Notes - [Advanced Numpy](http://scipy-lectures.github.io/advanced/advanced_numpy/index.html#advanced-numpy)
3. [IPython中的计时和性能分析](http://pynash.org/2013/03/06/timing-and-profiling.html)

