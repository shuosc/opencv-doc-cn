#使用kNN进行手写字符的OCR {#tutorial_py_knn_opencv_cn}

##目标

在这一章当中

- 我们将使用我们在kNN上的知识来构建一个基本的OCR应用程序。
- 我们将尝试使用OpenCV提供的数字和字母数据。

## 手写数字OCR

我们的目标是建立一个可以读取手写数字的应用程序。为此，我们需要一些train_data和test_data。 OpenCV带有一个图像digits.png（在文件夹opencv/samples/data/中），其中有5000个手写数字（每个数字500个）。每个数字是一个20x20的图像。所以我们的第一步是将这个图像分成5000个不同的数字。对于每个数字，我们把它压成一个400像素的单行。这是我们的特性集，即所有像素的强度值。这是我们可以创建的最简单的特性集。我们使用每个数字的前250个样本作为train_data，然后使用250个样本作为test_data。所以让我们先准备好这些样本。

```python
import numpy as np
import cv2
from matplotlib import pyplot as plt

img = cv2.imread('digits.png')
gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

# 将图片分成5000块，每块都是20x20的大小
cells = [np.hsplit(row,100) for row in np.vsplit(gray,50)]

# 将其放入Numpy数组，数组的大小为(50,100,20,20)
x = np.array(cells)

# 准备train_data和test_data
train = x[:,:50].reshape(-1,400).astype(np.float32) # Size = (2500,400)
test = x[:,50:100].reshape(-1,400).astype(np.float32) # Size = (2500,400)

# 给测试集和训练集准备labels
k = np.arange(10)
train_labels = np.repeat(k,250)[:,np.newaxis]
test_labels = train_labels.copy()

# 初始化kNN, 训练, 用k=1测试
knn = cv2.ml.KNearest_create()
knn.train(train, cv2.ml.ROW_SAMPLE, train_labels)
ret,result,neighbours,dist = knn.findNearest(test,k=5)

# 检测分类的正确性
# 要做到这一点，将result和test_labels比较
matches = result==test_labels
correct = np.count_nonzero(matches)
accuracy = correct*100.0/result
```

所以我们的基本OCR应用程序已经好了。这个特殊的例子给了我一个91％的准确性。提高准确性的一个选择是为训练添加更多的数据，特别是错误的数据。

我不希望每次打开应用程序时都要找到这个训练数据，而是最好将它保存下来，以便下一次直接从文件中读取这些数据并开始分类。你可以在`np.savetxt`，`np.savez`，`np.load`等Numpy函数的帮助下完成。请检查他们的文档了解更多细节。

```python
# 保存数据
np.savez('knn_data.npz',train=train, train_labels=train_labels)

# 加载数据
with np.load('knn_data.npz') as data:
    print( data.files )
    train = data['train']
    train_labels = data['train_labels']
```

在我的系统中，这大约需要4.4 MB的内存。由于我们使用强度值（uint8数据）作为特征，最好先将数据转换为np.uint8，然后再保存。这种情况下只需要1.1 MB。然后在加载的时候，你可以将其转换回float32。

## 英文字母OCR

接下来，我们将为英文字母做同样的事情，但是数据和功能集略有变化。在这里，OpenCV不提供图像，而是在opencv/samples/cpp/文件夹中带有一个数据文件letter-recognition.data。如果你打开它，你会看到20000行数据，第一眼看上去就像是垃圾数据。实际上，在每一行中，第一列是我们字母的标签。接下来的16个数字是它的不同特征。这些功能是从UCI机器学习仓库中获得的。您可以在[此页面](http://archive.ics.uci.edu/ml/)找到这些特征的详细信息。

有20000个样本，所以我们先取10000个数据作为训练样本，剩下10000个样本作为测试样本。我们应该使用字母ascii码，因为我们不能直接使用字母。

```python
import cv2
import numpy as np
import matplotlib.pyplot as plt

# 读取数据，将字母转换成数字
data= np.loadtxt('letter-recognition.data', dtype= 'float32', delimiter = ',',
                    converters= {0: lambda ch: ord(ch)-ord('A')})

# 将数据分成两份，训练集和测试集各10000组数据
train, test = np.vsplit(data,2)

# 将trainData和testData分成features和responses
responses, trainData = np.hsplit(train,[1])
labels, testData = np.hsplit(test,[1])

# 初始化kNN，分类，测定准确度
knn = cv2.ml.KNearest_create()
knn.train(trainData, cv2.ml.ROW_SAMPLE, responses)
ret, result, neighbours, dist = knn.findNearest(testData, k=5)

correct = np.count_nonzero(result == labels)
accuracy = correct*100.0/10000
print( accuracy )
```

它给了我一个93.22％的准确性。再一次，如果你想提高准确性，你可以迭代地添加每个级别的错误数据。