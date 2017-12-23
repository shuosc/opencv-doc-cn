# OpenCV-Python简介教程 {#tutorial_py_intro_cn}

## OpenCV

OpenCV于1999年由**Gary Bradsky**在英特尔开始开发，于2000年首次发布。

**Vadim Pisarevsky**加入了Gary Bradsky来管理俄罗斯英特尔软件OpenCV团队。 在赢得2005年DARPA大挑战的车辆Stanley上使用了OpenCV。后来，在Willow Garage的支持和在Gary Bradsky、Vadim Pisarevsky的领导下这个项目继续活跃发展。 OpenCV现在支持多种与计算机视觉和机器学习有关的算法，并且正在日益扩大。

OpenCV支持多种编程语言，如C++，Python，Java等，可在不同的平台上使用，包括Windows，Linux，OS X，Android和iOS。基于CUDA和OpenCL的高速GPU运算接口也在活跃开发之中。

OpenCV-Python是OpenCV的Python API，结合了OpenCV C++ API和Python语言的优势。

## OpenCV-Python

OpenCV-Python是为解决计算机视觉问题而设计的Python绑定库。

Python是一种通用编程语言，由**Guido van Rossum**开发，它很快变得非常流行，主要是因为它的简单性和代码可读性。它使程序员能够用更少的代码行表达想法，而不会降低可读性。

与C/C ++等语言相比，Python更慢。但是Python可以很容易地用C/C++进行扩展，这允许我们用C/C++编写计算密集的代码，并创建作为Python模块使用的Python包装器。这带给我们两个好处：第一，代码和原来的C/C++代码一样快（因为在后台工作的实际上是C++代码），第二，写Python比写C/C++代码更容易。 OpenCV-Python是原始OpenCV C++实现的Python包装器。

OpenCV-Python使用了**Numpy**，一个高度优化的数组操作库，它使用MATLAB风格的语法。所有的OpenCV数组结构都转换会转换成Numpy数组或自Numpy数组转换而来。

这也使得OpenCV-Python与其他使用Numpy的库（如SciPy和Matplotlib）更容易集成。

## OpenCV-Python教程

OpenCV引入了一套新的教程，将指导您学会OpenCV-Python中的各种功能。本教程主要使用OpenCV 3.x版本（尽管大部分教程也适用于OpenCV 2.x）。

建议先学习Python和Numpy的知识，因为本指南不会涉及它们。

**为了使用OpenCV-Python编写最优化的代码，熟练使用Numpy是必须的。**

本教程最初由Abid Rahman K.开始编写，作为Alexander Mordvintsev指导下的Google Summer of Code 2013计划的一部分。

## OpenCV需要你！！！

由于OpenCV是一个开源计划，欢迎任何人为库，文档和教程作出贡献。如果您在本教程中发现任何错误（从小的拼写错误到代码或概念中的严重错误），请随时通过在[GitHub](https://github.com/opencv/opencv)上clone OpenCV并提交pull request来纠正错误。 OpenCV开发人员将检查您的pull request，给您重要的反馈，并且（一旦通过审阅者批准），它将被合并到OpenCV中。您将成为开源贡献者:-)

当新的模块被添加到OpenCV-Python中时，本教程将不得不被扩展。如果你熟悉一个特定的算法，可以写一个包括算法的基本理论和示例用法的代码的教程，请这样做。

请记住，我们**一起努力**可以使这个项目取得巨大的成功！

## 贡献者

以下是提交OpenCV-Python教程的贡献者列表。

- Alexander Mordvintsev（GSoC-2013导师）
- Abid Rahman K.（GSoC-2013实习生）

## 更多资源

1. A Quick guide to Python - [A Byte of Python](http://swaroopch.com/notes/python/)
2. [Basic Numpy Tutorials](http://wiki.scipy.org/Tentative_NumPy_Tutorial)
3. [Numpy Examples List](http://wiki.scipy.org/Numpy_Example_List)
4. [OpenCV Documentation](http://docs.opencv.org/)
5. [OpenCV Forum](http://answers.opencv.org/questions/)