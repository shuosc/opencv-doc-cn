# 开始使用视频{#tutorial_py_video_display_cn}

## 目标

- 学习读取视频、显示视频和保存视频。
- 学习使用摄像头拍摄视频并将其显示出来。
- 你会学到这些函数：`cv2.VideoCapture()`、`cv2.VideoWriter()`

## 用摄像头拍摄视频

通常，我们必须用摄像头拍摄实时视频流。 OpenCV为此提供了一个非常简单的接口。

让我们从摄像头中拍摄视频（我使用我的笔记本电脑的内置摄像头），将其转换为灰度视频并显示。 这只是一个用来上手的简单任务。

要拍摄视频，您需要创建一个VideoCapture对象。 它的参数可以是设备索引或视频文件的名称。 设备索引是指定哪个摄像头的号码。

通常只有一个摄像头被连接到电脑上（就像我的情况）。 所以我只是传入0（或-1）。 您可以通过传入1等参数来选择第二台相机。 之后，您可以逐帧拍摄。 在最后，不要忘记释放VideoCapture对象。

```python
import numpy as np
import cv2
cap = cv2.VideoCapture(0)
while True:
    # 逐帧捕获
	ret, frame = cap.read()

	# 对帧进行处理
	gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

	# 显示出结果帧
	cv2.imshow('frame',gray)
	if cv2.waitKey(1) & 0xFF == ord('q'):
    	break
# 当一切结束以后，释放VideoCapture对象
cap.release()
cv2.destroyAllWindows()
```

`cap.read()`返回一个`bool`值（`True/False`）。如果成功的获取到了视频帧，这个值将会是`True`。你可以通过这个返回值检查是否到达了一段视频的结尾。

有时，`cap`可能没有初始化捕获。 在这种情况下，这段代码会报错。 你可以通过`cap.isOpened()`方法检查它是否被初始化。 如果它返回`True`，那就没问题。否则使用`cap.open()`打开它。

您还可以使用`cap.get(propId)`方法访问此视频的一些属性，其中`propId`是一个从0到18的数字。每个数字表示视频的一个属性（如果该属性适用于该视频），全部细节请参阅`cv::VideoCapture::get()`的文档。

其中一些值可以使用`cap.set(propId,value)`进行修改。 `value`是你想要的新值。

例如，我们可以使用检查`cap.get(cv2.CAP_PROP_FRAME_WIDTH)`和`cap.get(cv2.CAP_PROP_FRAME_HEIGHT)`一个视频帧的宽度和高度。默认情况下是 640x480。但如果我想要把它改成 320x240。我只需要使用`ret = cap.set(cv2.CAP_PROP_FRAME_WIDTH,320)` 和`ret = cap.set(cv2.CAP_PROP_FRAME_HEIGHT,240)`。

如果在用摄像头拍摄视频时出现了错误，请先用其他摄像头软件（如linux下的Cheese）确保你的摄像头本身工作正常。

## 从文件中播放视频

与从相机拍摄相同，只需将摄像头索引替换为视频文件名称即可。 在显示帧的同时，使用`cv2.waitKey()`来延迟适当的时间。 如果延迟时间太少，视频会非常快，如果太多，视频会很慢（这就是如何以慢动作显示视频）。 正常情况下25毫秒是一个比较合适的值。

```python
import numpy as np
import cv2
cap = cv2.VideoCapture('vtest.avi')
while(cap.isOpened()):
	ret, frame = cap.read()
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    cv2.imshow('frame',gray)
	if cv2.waitKey(1) & 0xFF == ord('q'):
   		break
cap.release()
cv2.destroyAllWindows()
```

确保安装了正确版本的ffmpeg或gstreamer。 有时，由于ffmpeg / gstreamer的安装错误，拍摄视频是一件非常头疼的事情。

## 保存一个视频

现在我们已经拍摄一个了视频，对其进行了逐帧处理，现在我们要保存视频。对于图像来说，保存非常简单，只需使用`cv2.imwrite()`即可。但对于视频来说这需要更多的工作。

我们需要创建一个`VideoWriter`对象。我们应该指定输出文件名（例如：output.avi）。接着我们需要指定**FourCC**代码（细节在下一段中描述）。然后传递每秒帧数（fps）和帧大小。最后一个是`isColor`标志。如果为`True`，则编码器使用彩色帧，否则使用灰度帧。

[FourCC](http://en.wikipedia.org/wiki/FourCC)是用于指定视频编解码器的4字节代码。可用的代码列表可以在[fourcc.org](http://www.fourcc.org/codecs.php)找到。这些代码依赖于平台。下面的编解码器在我的环境下工作正常。

- 在Fedora下：DIVX，XVID，MJPG，X264，WMV1，WMV2。 （优先选择XVID，MJPG会产生很大的视频。 X264提供非常小尺寸的视频）
- 在Windows下：DIVX（更多格式需要等待进一步测试和添加）
- 在OS X下：MJPG（.mp4），DIVX（.avi），X264（.mkv）。

以MJPG格式为例，`FourCC`代码是像这样传入的：`cv2.VideoWriter_fourcc('M'，'J'，'P'，'G')`或`cv2.VideoWriter_fourcc(*'MJPG')`。

下面的代码从摄像头拍摄视频，在垂直方向翻转每一帧并保存。

```python
import numpy as np
import cv2
cap = cv2.VideoCapture(0)
# 定义解码器并创建VideoWriter对象
fourcc = cv2.VideoWriter_fourcc(*'XVID')
out = cv2.VideoWriter('output.avi',fourcc, 20.0, (640,480))
while cap.isOpened():
    ret, frame = cap.read()
	if ret:
    	frame = cv2.flip(frame,0)
    	# 写入翻转过的帧
    	out.write(frame)
    	cv2.imshow('frame',frame)
    	if cv2.waitKey(1) & 0xFF == ord('q'):
        	break
	else:
    	break
# 工作完成后释放所有的东西
cap.release()
out.release()
cv2.destroyAllWindows()
```

