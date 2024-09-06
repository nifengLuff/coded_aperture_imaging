"""
Pinhole Imaging MLP Reconstruction
"""
import numpy as np
import torch
import random
import os
import re
import matplotlib.pyplot as plt
import torch.nn.functional as F
from torch.utils.data import DataLoader, TensorDataset
from sklearn.model_selection import train_test_split

total_epoch = 10000
detector_scale = 16
directory = 'simulation_data'
batch_size = 32

images = np.zeros((0, 1, detector_scale, detector_scale))
objects = np.zeros((detector_scale*detector_scale, detector_scale*detector_scale))
# 遍历指定路径下的所有文件
i = 0
for filename in os.listdir(directory):
    if filename.endswith("_imaging_phot_peak_count.txt"):
        image = []
        # 构建完整的文件路径
        file_path = os.path.join(directory, filename)
        # 打开文件
        with open(file_path, "r") as file:
            for line in file:
                # 从每行中提取整数并存储到数组中
                line_data = [float(num) for num in line.strip().split()]
                # image.append(line_data)  # 将新的一行连接到一维数组的末尾
                
                image.append(line_data)
                # print(image)
        # image_array = np.array(image)
        # images = np.vstack([images, image_array])
        # images.append(image)
        # 找到最大值和最小值
        max_value = np.max(image)
        min_value = np.min(image)
        normalized_image = -1 + 2 * (image - min_value) / (max_value - min_value)
        # 如果需要将归一化后的值替换原始数组中的值，可以这样操作
        image = normalized_image

        image = np.array(image)
        image = image[np.newaxis, np.newaxis, :, :]  # 添加两个新维度，表示样本和通道
        images = np.concatenate((images, image), axis=0)  # 添加到样本集中

        # 使用正则表达式提取数字
        match = re.search(r'x_(\d+)_y_(\d+)', filename)

        if match:
            x = int(match.group(1))  # 提取第一个数字并转换为整数
            y = int(match.group(2))  # 提取第二个数字并转换为整数
            # pixel_order = x + detector_scale*(detector_scale - y - 1)
            # objects[i, pixel_order] = 1
            objects[i, (detector_scale - y - 1)*detector_scale + x] = 1
            i = i + 1
        else:
            print("未找到匹配的数字")

# print(images.shape)
class CNN(torch.nn.Module):
    def __init__(self):
        super(CNN, self).__init__()
        # 第一层:卷积层
        self.conv1 = torch.nn.Conv2d(1, 10, kernel_size = 3, padding = 0)
        # 第二层:池化层
        self.pool = torch.nn.MaxPool2d(2, 2)
        # 第三层:卷积层
        self.conv2 = torch.nn.Conv2d(10, 10, kernel_size = 3, padding = 0)
        # 第四层:全连接层
        self.fc = torch.nn.Linear(250, 256)
    
    def forward(self, x):
        x = self.pool(F.relu(self.conv1(x)))
        x = F.relu(self.conv2(x))
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        x = torch.sigmoid(x)
        return x

loss = torch.nn.MSELoss()
model = CNN()
opt = torch.optim.Adam(params = model.parameters(), lr = 0.0001)
min_loss = 10
not_min_loss_count = 0
# 将数据转换为Tensor
# images_tensor = torch.tensor(images, dtype=torch.float32)
# objects_tensor = torch.tensor(objects, dtype=torch.float32)

for epoch in range(total_epoch):
    images_train, images_test, objects_train, objects_test = train_test_split(images, objects, test_size=0.1, random_state=epoch)
    
    # 将数据转换为 PyTorch 的 Tensor
    images_train_tensor = torch.tensor(images_train, dtype=torch.float32)
    objects_train_tensor = torch.tensor(objects_train, dtype=torch.float32)
    images_test_tensor = torch.tensor(images_test, dtype=torch.float32)
    objects_test_tensor = torch.tensor(objects_test, dtype=torch.float32)

    # 创建 DataLoader
    train_dataset = TensorDataset(images_train_tensor, objects_train_tensor)
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)

    # 训练模型
    for images_batch, objects_batch in train_loader:
        opt.zero_grad()
        output = model(images_batch)
        l = loss(output, objects_batch)
        # print(epoch, l.item())
        l.backward()
        opt.step()
    
    # 在每个 epoch 结束时进行测试集评估
    with torch.no_grad():
        output_test = model(images_test_tensor)
        l_test = loss(output_test, objects_test_tensor)
        print(f"Epoch {epoch}, Test Loss: {l_test.item()}, Loss stop: {not_min_loss_count}")
        if l_test.item() < min_loss:
            min_loss = l_test.item()
            not_min_loss_count = 0
        else:
            not_min_loss_count = not_min_loss_count + 1
    
    if not_min_loss_count > 1000:
        break

# directory = 'simulation_data'
# image_test = []
# filename = 'x_8_y_6_imaging_phot_peak_count.txt'

directory = 'test_data'
filename = 'raw_spectrum_calibrated_select_counts.txt'

images_test = np.zeros((0, 1, detector_scale, detector_scale))
print(images_test.shape)

image_test = []
# 构建完整的文件路径
file_path = os.path.join(directory, filename)
# 打开文件
with open(file_path, "r") as file:
    for line in file:
        # 从每行中提取整数并存储到数组中
        line_data = [float(num) for num in line.strip().split()]

        image_test.append(line_data)
        # print(image)
# image_array = np.array(image)
# images = np.vstack([images, image_array])
# images.append(image)
# 找到最大值和最小值
max_value = np.max(image_test)
min_value = np.min(image_test)
normalized_image_test = -1 + 2 * (image_test - min_value) / (max_value - min_value)
# 如果需要将归一化后的值替换原始数组中的值，可以这样操作
image_test = normalized_image_test

image_test = np.array(image_test)
plt.rcParams['font.family'] = 'Times New Roman'
plt.imshow(image_test)
plt.colorbar()  # 显示颜色条
plt.axis('on')  # 关闭坐标轴
plt.show(block = False)
image_test = image_test[np.newaxis, np.newaxis, :, :]  # 添加两个新维度，表示样本和通道
images_test = np.concatenate((images_test, image_test), axis=0)  # 添加到样本集中

# print(image_test.shape)
# print(images_test.shape)
# image_test_array = np.array(image_test)
# image_test_array_tensor = torch.tensor(image_test_array, dtype=torch.float32)
images_test_tensor = torch.tensor(images_test, dtype=torch.float32)
object_test_tensor = model(images_test_tensor)
# print(object_test_tensor.shape)

object_test = np.zeros((16, 16))
for i in range(detector_scale):
    for j in range(detector_scale):
        object_test[i, j] = object_test_tensor[0, i*detector_scale + j]

plt.figure()
plt.imshow(object_test)
plt.colorbar()  # 显示颜色条
plt.axis('on')  # 关闭坐标轴
plt.show()

def write_2d_array_to_txt(array, filename):
    with open(filename, 'w') as f:
        for row in array:
            row_str = '\t'.join(map(str, row))  # 将每行转换为字符串，用制表符分隔
            f.write(row_str + '\n')  # 写入每行，并添加换行符

# 将二维数组写入到文件中
write_2d_array_to_txt(object_test, '重建结果2_14.txt')