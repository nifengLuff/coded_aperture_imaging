"""
Pinhole Imaging MLP Reconstruction
"""
import numpy as np
import torch
import random
import os
import re
import matplotlib.pyplot as plt

total_epoch = 1000
detector_scale = 16
directory = 'simulation_data'

images = np.empty((0, detector_scale*detector_scale))
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
                line_data = [int(num) for num in line.strip().split()]
                image = np.concatenate((image, line_data))  # 将新的一行连接到一维数组的末尾
        image_array = np.array(image)
        images = np.vstack([images, image_array])

        # 使用正则表达式提取数字
        match = re.search(r'x_(\d+)_y_(\d+)', filename)

        if match:
            x = int(match.group(1))  # 提取第一个数字并转换为整数
            y = int(match.group(2))  # 提取第二个数字并转换为整数
            pixel_order = x + detector_scale*(detector_scale - y - 1)
            objects[i, pixel_order] = 1
            i = i + 1
        else:
            print("未找到匹配的数字")

class MLP(torch.nn.Module):
    def __init__(self):
        super(MLP, self).__init__()
        self.net = torch.nn.Sequential(
            torch.nn.Linear(detector_scale*detector_scale, detector_scale*detector_scale),
            torch.nn.ReLU(),
            # torch.nn.Dropout(0.1),  # 添加丢弃层
            torch.nn.Linear(detector_scale*detector_scale, detector_scale*detector_scale),
            torch.nn.ReLU(),
            # torch.nn.Dropout(0.1),  # 添加丢弃层
            torch.nn.Linear(detector_scale*detector_scale, detector_scale*detector_scale),
            # torch.nn.ReLU(),
        )
    def forward(self, x):
        return self.net(x)

loss = torch.nn.MSELoss()
model = MLP()
opt = torch.optim.Adam(params = model.parameters(), lr = 0.0001)

# 将数据转换为Tensor
images_tensor = torch.tensor(images, dtype=torch.float32)
objects_tensor = torch.tensor(objects, dtype=torch.float32)

for epoch in range(total_epoch):
    opt.zero_grad()
    output = model(images_tensor)
    l = loss(output, objects_tensor)
    print(epoch, l.item())
    l.backward()
    opt.step()

# directory = 'simulation_data'
# image_test = []
# filename = 'x_4_y_14_imaging_phot_peak_count.txt'

directory = 'test_data'
image_test = []
filename = '511keV_40.0cm_20.0cm_3mm_imaging_phot_peak_count.txt'

# 构建完整的文件路径
file_path = os.path.join(directory, filename)
# 打开文件
with open(file_path, "r") as file:
    for line in file:
        # 从每行中提取整数并存储到数组中
        line_data = [int(num) for num in line.strip().split()]
        image_test = np.concatenate((image_test, line_data))  # 将新的一行连接到一维数组的末尾

image_test_array = np.array(image_test)
image_test_array_tensor = torch.tensor(image_test_array, dtype=torch.float32)
object_test_array_tensor = model(image_test_array_tensor)
print(object_test_array_tensor)

reshaped_object_test_array_tensor = object_test_array_tensor.view(detector_scale, detector_scale)
print(reshaped_object_test_array_tensor)
# 使用Matplotlib库显示图像
plt.imshow(reshaped_object_test_array_tensor.detach().numpy())
plt.colorbar()  # 显示颜色条
plt.axis('off')  # 关闭坐标轴
plt.show()
