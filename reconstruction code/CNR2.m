disp('原始矩阵:');
disp(Shat);

% 设置要计算的前 N 个最大值
N = 3;

% 找到矩阵中最大的 N 个点
[~, indices] = maxk(Shat(:), N);

% 计算最大的 N 个点的平均值
topN_mean = mean(Shat(indices));

% 剔除最大的 N 个点后，计算其余点的平均值和标准差
Shat(indices) = [];
rest_mean = mean(Shat(:));
rest_std = std(Shat(:));

% 显示结果
disp(['前', num2str(N), '个最大值的平均值：', num2str(topN_mean)]);
disp(['其余点的平均值：', num2str(rest_mean)]);
disp(['其余点的标准差：', num2str(rest_std)]);
disp(['CNR：', num2str((topN_mean - rest_mean)/rest_std)]);