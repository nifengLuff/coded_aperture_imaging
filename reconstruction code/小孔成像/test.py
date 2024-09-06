import numpy as np
import matplotlib.pyplot as plt
from numpy.fft import fft2, fftshift
import os

directory = 'test_data'
filename = 'raw_spectrum_calibrated_select_counts.txt'
image = []
# 构建完整的文件路径
file_path = os.path.join(directory, filename)

with open(file_path, "r") as file:
    for line in file:
        # 从每行中提取整数并存储到数组中
        line_data = [float(num) for num in line.strip().split()]
        # image.append(line_data)  # 将新的一行连接到一维数组的末尾
        
        image.append(line_data)

# 找到最大值和最小值
max_value = np.max(image)
min_value = np.min(image)
normalized_image = -1 + 2 * (image - min_value) / (max_value - min_value)
# 如果需要将归一化后的值替换原始数组中的值，可以这样操作
image = normalized_image
# # 生成一个随机的16x16像素的图像
# image = np.random.rand(16,16)

# 对该图像进行二维快速傅里叶变换
fft_image = fft2(image)

# 将频率零点移至频谱中心
fft_shifted = fftshift(fft_image)

# 计算幅度谱
magnitude_spectrum = np.abs(fft_shifted)

# 绘制原始图像和幅度谱
fig, ax = plt.subplots(1, 2, figsize=(12, 6))

# 原始图像
ax[0].imshow(image)
ax[0].set_title("Original Image")
ax[0].axis('off')

# 幅度谱
ax[1].imshow(np.log(1 + magnitude_spectrum)) # 使用对数变换以改善显示
ax[1].set_title("Magnitude Spectrum")
ax[1].axis('off')

plt.show()