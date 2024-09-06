import numpy as np
import matplotlib.pyplot as plt

file_path = 'E:\毕设\重建代码\小孔成像\\test_data\\511keV_40.0cm_20.0cm_3mm_imaging_phot_peak_count.txt'

# 由于没有实际文件，这里提供代码样例，你可以在你的环境中运行它
try:
    # 读取文件中的数据并转换成numpy数组
    matrix = np.loadtxt(file_path)

    # 绘制热图
    plt.figure(figsize=(8, 6))
    plt.imshow(matrix, cmap='viridis', interpolation='nearest')
    plt.colorbar()  # 添加颜色条
    plt.title('Matrix Heatmap from Real')
    plt.show()
except Exception as e:
    print(f"读取文件或绘图时发生错误: {e}")