# OpenCV-Python绑定如何工作？ {#tutorial_py_bindings_basics_cn}

##目标

学习：

- 如何OpenCV-Python绑定是如何生成的？
- 如何扩展新的OpenCV模块到Python？

##OpenCV-Python绑定是如何生成的？

在OpenCV中，所有的算法都是用C++实现的。但是这些算法可以在Python，Java等不同的语言中使用，这是通过绑定生成器实现的。这些生成器在C++和Python之间建立了桥梁，使用户可以从Python调用C++函数。为了全面了解后台发生的事情，需要熟悉Python/C API。有关将C++函数扩展到Python的一个简单示例，请参见Python官方文档。

通过手动编写包装函数将OpenCV中的所有函数扩展为Python是一项非常耗时的任务。所以OpenCV以更智能的方式做到这一点。 OpenCV使用位于modules/python/src2中的一些Python脚本从C++头文件自动生成这些包装函数。我们会看看他们做了什么。

首先，modules/python/CMakeFiles.txt是一个CMake脚本，用于检查要扩展到Python的模块。它会自动检查所有要扩展的模块并抓取它们的头文件。

这些头文件包含特定模块的所有类，函数，常量等的列表。

其次，这些头文件被传递给Python脚本modules/python/src2/gen2.py。这是Python绑定生成器脚本。它调用另一个Python脚本modules/python/src2/hdr_parser.py。

这是头文件解析器脚本。这个头解析器将完整的头文件分割成小的Python列表。因此，这些列表包含关于特定函数，类等的所有细节。例如，函数将被解析以获取包含函数名称，返回类型，输入参数，参数类型等的列表。最终列表包含所有函数，结构，头文件中的类等。

但是头文件解析器不会解析头文件中的所有函数/类。开发者必须指定哪些函数应该被导出到Python。为此，在这些声明的开始处添加了一些宏，使得头文件解析器能够识别要解析的函数。这些宏由编程特定功能的开发人员添加。总之，开发人员决定哪些功能应该扩展到Python，哪些不是。这些宏的细节将在下一章中提供。

所以头解析器返回一个解析函数的最终大列表。我们的生成器脚本（gen2.py）将为头文件解析器分析的所有函数/类/枚举/结构创建包装函数（可以在编译过程中在build/modules/python/文件夹中找到这些头文件，如pyopencv_generated _*.h 文件）。但是可能会有一些基本的OpenCV数据类型，如Mat，Vec4i，Size。他们需要手动扩展。例如，Mat类型应该扩展为Numpy数组，Size应该扩展为两个整数的元组等等。类似地，可能有一些复杂的结构/类/函数等需要手动扩展。所有这些手动包装函数都放在modules/python/src2/cv2.cpp中。

所以现在唯一剩下要做的事就是编译这些包装文件，它给了我们`cv2`模块。所以，当你在Python中调用一个函数，例如`res = equalizeHist(img1,img2)`，你传入了两个numpy数组，你期望另一个numpy数组作为输出。所以这些numpy数组被转换为`cv::Mat`，然后在C ++中调用`equalizeHist()`函数。最终的结果是，res会被转换回一个Numpy数组。所以简而言之，几乎所有的操作都是用C++来完成的，它的速度几乎和C++一样。

所以这是如何生成OpenCV-Python绑定的基本版本。

##如何扩展新的模块到Python？

头文件解析器根据添加到函数声明中的一些包装宏解析头文件。

枚举常量不需要任何包装宏。他们被自动包装。但是剩下的函数，类等需要包装宏。

函数使用`CV_EXPORTS_W`宏进行扩展。一个例子如下所示。

```c++
CV_EXPORTS_W void equalizeHist( InputArray src, OutputArray dst );
```

头文件解析器可以理解InputArray，OutputArray等关键字的输入和输出参数。但有时，我们可能需要对输入和输出进行硬编码。为此，使用像`CV_OUT`，`CV_IN_OUT`等宏。

```c++
CV_EXPORTS_W void minEnclosingCircle( InputArray points,
                                     CV_OUT Point2f& center, CV_OUT float& radius );
```



对于大的Class，也使用`CV_EXPORTS_W`。为了扩展类方法，使用了`CV_WRAP`。

同样，`CV_PROP`用于类字段。

```c++
class CV_EXPORTS_W CLAHE : public Algorithm
{
public:
    CV_WRAP virtual void apply(InputArray src, OutputArray dst) = 0;

    CV_WRAP virtual void setClipLimit(double clipLimit) = 0;
    CV_WRAP virtual double getClipLimit() const = 0;
}
```

重载函数可以使用`CV_EXPORTS_AS`进行扩展。 但是我们需要传递一个新的名字，这样每个函数都会在Python中被这个名字所调用。 以下是`integral`函数的情况。 有三个函数可用，所以每个函数都用Python中的后缀命名。 同样，`CV_WRAP_AS`可以用来包装重载的方法。

```c++
//! 计算图像积分
CV_EXPORTS_W void integral( InputArray src, OutputArray sum, int sdepth = -1 );

//! 计算平方图像的积分和原图像的积分
CV_EXPORTS_AS(integral2) void integral( InputArray src, OutputArray sum,
                                        OutputArray sqsum, int sdepth = -1, int sqdepth = -1 );

//! 计算图像积分，平方图像积分和倾斜图像积分
CV_EXPORTS_AS(integral3) void integral( InputArray src, OutputArray sum,
                                        OutputArray sqsum, OutputArray tilted,
                                        int sdepth = -1, int sqdepth = -1 );
```

小的类/结构体使用`CV_EXPORTS_W_SIMPLE`进行扩展。 这些结构被传递给C++函数。 例如`KeyPoint`，`Match`等。它们的方法由`CV_WRAP`扩展，字段由`CV_PROP_RW`扩展。

```c++
class CV_EXPORTS_W_SIMPLE DMatch
{
public:
    CV_WRAP DMatch();
    CV_WRAP DMatch(int _queryIdx, int _trainIdx, float _distance);
    CV_WRAP DMatch(int _queryIdx, int _trainIdx, int _imgIdx, float _distance);
    
    CV_PROP_RW int queryIdx; // query descriptor index
    CV_PROP_RW int trainIdx; // train descriptor index
    CV_PROP_RW int imgIdx;   // train image index
    
    CV_PROP_RW float distance;
};
```

其他一些小的类/结构可以使用`CV_EXPORTS_W_MAP`导出到Python本地字典中。 `Moments()`就是一个例子。

```c++
class CV_EXPORTS_W_MAP Moments
{
public:
    //! 空间矩
    CV_PROP_RW double  m00, m10, m01, m20, m11, m02, m30, m21, m12, m03;
    //! 中心矩
    CV_PROP_RW double  mu20, mu11, mu02, mu30, mu21, mu12, mu03;
    //! 中心归一化矩
    CV_PROP_RW double  nu20, nu11, nu02, nu30, nu21, nu12, nu03;
};
```

所以这些是OpenCV中可用的主要扩展宏。 通常情况下，开发人员必须将适当的宏放在适当的位置。 剩余工作是由生成器脚本完成的。 有时候，可能会有一些例外的情况，即生成器脚本不能创建包装器。 这样的函数需要手动处理，为此请编写自己的pyopencv _*.hpp扩展头文件，并将它们放到模块的misc/python子目录中。 但是大多数情况下，根据OpenCV编码准则编写的代码将被生成器脚本自动包装。