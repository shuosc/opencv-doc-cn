#OpenCV中的K-Means聚类{#tutorial_py_kmeans_opencv_cn}

## 目标

- 学习在OpenCV中使用`cv2.kmeans()`函数进行数据聚类

## 了解参数

###输入参数

- `samples`：应该是`np.float32`数据类型，每个特征应放在一个单独的列中。
- `nclusters`(K)：结束时所需的集群数量
- `criteria`：这是迭代终止标准。当满足这个标准时，算法迭代停止。其实它应该是一个3个参数的元组。他们是`(type,max_iter,epsilon)`：
  - 终止标准的类型。它有3个标志如下：

    `cv2.TERM_CRITERIA_EPS` - 如果达到了指定的精度`epsilon`，则停止算法迭代。

    `cv2.TERM_CRITERIA_MAX_ITER` - 在指定的迭代次数max_iter之后停止算法。

    `cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER` - 当满足上述任何条件时停止迭代。
   - `max_iter` - 指定最大迭代次数的整数。
   - `epsilon` - 所需的准确性
- `attempts`：标志来指定使用不同的起始标签执行算法的次数。该算法返回产生最佳紧凑性的标签。这种紧凑性作为输出返回。
- flags：这个标志用于指定如何初始中心。通常使用两个标志：`cv2.KMEANS_PP_CENTERS`和`cv2.KMEANS_RANDOM_CENTERS`。

###输出参数

- `compactness`：它是从每个点到相应中心的平方距离的总和。
- `labels`：这是标签数组（与上一篇文章中的'代码'部分相同）每个元素
    标记为“0”，“1”......
- `centers`：这是集群中心的数组。

现在我们来看看如何应用K-Means算法和三个例子。

1. 只有一个特征的数据
  考虑一下，你有一组数据只有一个特征，即一维。例如，我们可以把T恤衫的问题简化成你只用身高来决定T恤衫的大小。

  所以我们首先创建数据并将其绘制在Matplotlib中

  ```python
  import numpy as np
  import cv2
  from matplotlib import pyplot as plt

  x = np.random.randint(25,100,25)
  y = np.random.randint(175,255,25)
  z = np.hstack((x,y))
  z = z.reshape((50,1))
  z = np.float32(z)
  plt.hist(z,256,[0,256]),plt.show()
  ```

  所以我们有一个大小为50，数值范围从0到255的数组“z”。我已经将“z”重新整形成一个列向量。当存在多个特征时，它将会更有用。然后我让data是np.float32类型的数据。

  我们得到以下图像：

  ![image](images/oc_1d_testdata.png)

  现在我们应用KMeans函数。在此之前，我们需要指定标准。我的标准是，算法每迭代运行10次，或着达到1.0的精度，就停止算法并返回答案。

  ```python
  # 定义终止条件 
  criteria = ( type, max_iter = 10 , epsilon = 1.0 )
  criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 10, 1.0)

  # 设置flags
  flags = cv2.KMEANS_RANDOM_CENTERS
  # 应用KMeans
  compactness,labels,centers = cv2.kmeans(z,2,None,criteria,10,flags)
  ```
  这给了我们compactness，labels和centers。在这种情况下，我得到的centers为60和207。标签将具有与测试数据相同的大小，其中每个数据将根据其质心标记为“0”，“1”，“2”等。现在我们根据其标签将数据分成不同的群集。

  ```python
  A = z[labels==0]
  B = z[labels==1]
  ```
  现在我们绘制红色的A和蓝色的B，以黄色绘制它们的质心。

  ```python
  # 现在用红色标出'A'，用蓝色标出'B'，用黄色标出'中心'
  plt.hist(A,256,[0,256],color = 'r')
  plt.hist(B,256,[0,256],color = 'b')
  plt.hist(centers,32,[0,256],color = 'y')
  plt.show()
  ```
  以下是我们得到的结果：

  ![image](images/oc_1d_clustered.png)

2. 具有多个特征的数据

   在前面的例子中，我们只考虑了T恤问题中的身高。在这里，我们将采取身高和体重，即两个特征。

   请记住，在以前的情况下，我们将数据转换为一个列向量。每个功能按列排列，每行对应一个输入测试样本。

   例如，在这种情况下，我们设置一个大小为50x2的测试数据，这个数据是50人的高度和权重。第一列对应于所有50人的身高，第二列对应于他们的体重。第一行包含两个元素，第一个是第一个人的高度，第二个是他的体重。同样剩下的行对应于其他人的身高和体重。

   检查下面的图像：

   ![image](images/oc_feature_representation.jpg)

   我直接上代码了：

   ```python
   import cv2
   from matplotlib import pyplot as plt

   X = np.random.randint(25,50,(25,2))
   Y = np.random.randint(60,85,(25,2))
   Z = np.vstack((X,Y))

   # 转换为np.float32
   Z = np.float32(Z)

   # 定义终止条件，应用kmeans算法
   criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 10, 1.0)
   ret,label,center=cv2.kmeans(Z,2,None,criteria,10,cv2.KMEANS_RANDOM_CENTERS)

   # 现在将数据分开
   A = Z[label.ravel()==0]
   B = Z[label.ravel()==1]

   # 绘制数据
   plt.scatter(A[:,0],A[:,1])
   plt.scatter(B[:,0],B[:,1],c = 'r')
   plt.scatter(center[:,0],center[:,1],s = 80,c = 'y', marker = 's')
   plt.xlabel('Height'),plt.ylabel('Weight')
   plt.show()
   ```

   下面是我们得到的输出：

   ![image](images/oc_2d_clustered.jpg)

3. 颜色量化

   色彩量化是减少图像中颜色数量的过程。 这样做的一个原因是减少内存。 有些时候，有些设备可能会有限制，只能生成有限数量的颜色。 在这些情况下，也需要进行颜色量化。 这里我们使用k-means聚类进行颜色量化。

   这里没有什么新东西可以解释。 有3个特征，比如R，G，B。 所以我们需要将图像重塑为一个Mx3大小的数组（M是图像中的像素数）。 在聚类之后，我们将质心值（也是R，G，B）应用于所有像素，从而得到的图像将具有指定数量的颜色。 接着我们需要将其重新塑造成原始图像的形状。

   下面是代码：

   ```python
   import numpy as np
   import cv2

   img = cv2.imread('home.jpg')
   Z = img.reshape((-1,3))

   # 转换到np.float32
   Z = np.float32(Z)

   # 定义标准，聚类数量K并应用KMeans
   criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 10, 1.0)
   K = 8
   ret,label,center=cv2.kmeans(Z,K,None,criteria,10,cv2.KMEANS_RANDOM_CENTERS)

   # 转回uint8，放入原图像
   center = np.uint8(center)
   res = center[label.flatten()]
   res2 = res.reshape((img.shape))

   cv2.imshow('res2',res2)
   cv2.waitKey(0)
   cv2.destroyAllWindows()
   ```

   下面是K=8时的结果：

   ![image](images/oc_color_quantization.jpg)

