clear; % 清空工作区
%dateSuffix = datestr(datetime('now'), 'yyyy-mm-dd');
% 定义保存图形的文件夹路径
% folderPath = './小孔成像重建结果';
% 检查文件夹是否存在，如果不存在，则创建
% if ~exist(folderPath, 'dir')
%     mkdir(folderPath);
% end
% spectrum = load('depth_correction_spectrum_calibrated.txt');
% coded_image = spectrum(:, 1:2);
% count = zeros(size(spectrum(:, 1)));
% for i = 1: 255
%     for j = 3: 2: 2002
%         if spectrum(i, j) > 450 && spectrum(i, j) < 550
%             count(i) = count(i) + spectrum(i, j + 1);
%         end
%     end
% end
% % sumOfEvenCols = sum(spectrum(:, 4:2:2002), 2);
% % coded_image(:, 3) = sumOfEvenCols;
% coded_image(:, 3) = count;
% % 创建一个空矩阵，大小根据x、y的最大值确定
% coded_image_fig = zeros(max(coded_image(:,2)), max(coded_image(:,1)));
% % 填充矩阵，其中newMatrix(:,3)包含对应的值
% for i = 1:size(coded_image, 1)
%     coded_image_fig(coded_image(i,2) + 1, coded_image(i,1) + 1) = coded_image(i,3);
% end
% data_name = "x_3_y_14_imaging_phot_peak_count";
% coded_image_fig = load('./小孔成像模拟数据/' + data_name + '.txt');
% foldersavePath = fullfile(folderPath, data_name);
% if ~exist(foldersavePath, 'dir')
%     mkdir(foldersavePath);
% end
detector_scale = 16;
folderPath = './小孔成像模拟数据';

% sample = load(fullfile(folderPath, "x_7_y_8_imaging_allenergy.txt"));
% sample_2 = reshape(sample.', 1, []);
% figure;
% imagesc(sample);

images = zeros(256, 256);
objects = zeros(256, 256);
txt_list = dir(fullfile(folderPath, '*imaging_phot_peak_count.txt'));
txt_num = numel(txt_list);
for i = 1:txt_num
    txt_name = txt_list(i).name;

    integer_matches = regexp(txt_name, '\d+', 'match');
    % 从匹配结果中获取第1和第2个整数
    x = str2double(integer_matches{1});
    y = str2double(integer_matches{2});
    pixel_order = x + 1 + detector_scale*(detector_scale - y - 1);
    image = load(fullfile(folderPath, txt_name));
    images(x*detector_scale + y + 1, :) = reshape(image.', 1, []);
    objects(x*detector_scale + y + 1, pixel_order) = 1;
end

% figure;
% plot(images(54, :));
% figure;
% plot(objects(54, :));
%%
%对个别像素进行修正
% coded_image_fig(2, 15) = round(0.125*(coded_image_fig(2, 16) + coded_image_fig(3, 16)...
%     + coded_image_fig(1, 16) + coded_image_fig(1, 15) + coded_image_fig(3, 15)...
%     + coded_image_fig(1, 14) + coded_image_fig(2, 14) + coded_image_fig(3, 14)));
% coded_image_fig(16, 16) = round(1.0/3.0*(coded_image_fig(16, 15) + coded_image_fig(15, 16)...
%     + coded_image_fig(15, 15)));
% coded_image_fig(7, 15) = round(0.2*(coded_image_fig(6, 14) + coded_image_fig(6, 15)...
%     + coded_image_fig(6, 16) + coded_image_fig(7, 14) + coded_image_fig(7, 16)));
% coded_image_fig(8, 15) = round(0.2*(coded_image_fig(9, 14) + coded_image_fig(9, 15)...
%     + coded_image_fig(9, 16) + coded_image_fig(8, 14) + coded_image_fig(8, 16)));
% 使用imagesc显示矩阵
% reduced_coded_image_fig = coded_image_fig(3:15, 3:15);
% figure;
% imagesc(reduced_coded_image_fig);

% 生成示例数据
temp = randperm(size(images, 1));

% 训练集200个样本
P_train = images(temp(1: 200), :)';
T_train = objects(temp(1: 200), :)';

% 测试集56个样本
P_test = images(temp(201: end), :)';
T_test = objects(temp(201: end), :)';

% 数据归一化
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input);
[t_train, ps_output] = mapminmax(T_train, 0, 1);

% 创建网络并设置参数
net = newff(p_train, t_train, 10);
net.trainParam.epochs = 1000;
net.trainParam.goal = 1e-3;
net.trainParam.lr = 0.01;

% 训练网络
net = train(net, p_train, t_train);



% input_data = images;
% target_data = objects;
% 
% % 创建神经网络
% net = feedforwardnet(detector_scale*detector_scale); % 这里隐藏层有256个神经元，你可以根据需要调整
% 
% % 划分数据集
% net.divideParam.trainRatio = 0.7; % 训练集占总数据的70%
% net.divideParam.valRatio = 0.15; % 验证集占总数据的15%
% net.divideParam.testRatio = 0.15; % 测试集占总数据的15%
% 
% % 训练神经网络
% [net, tr] = train(net, input_data', target_data');
% 
% % 用训练好的神经网络进行预测
% predicted_data = net(input_data');
% 
% % 显示结果
% disp('原始数据:');
% disp(input_data);
% disp('预测数据:');
% disp(predicted_data);

%%
figure;
imagesc(coded_image_fig);
colorbar; % 显示颜色条
axis equal; % 保证x和y轴的刻度一致
xlim([0.5, 16.5])
ylim([0.5, 16.5])
xlabel('X', 'FontName', 'Times New Roman');
ylabel('Y', 'FontName', 'Times New Roman');
colormap(gca, slanCM(167))
title('Coded Image', 'FontName', 'Times New Roman');
filename_1 = fullfile(foldersavePath, data_name + '_coded_image_' + '.png');
filename_2 = fullfile(foldersavePath, data_name + '_coded_image_' + '.fig');
filename_3 = fullfile(foldersavePath, data_name + '_coded_image_' + '.tif');
set(gca, 'FontName', 'Times New Roman')
saveas(gcf, filename_1);
saveas(gcf, filename_2);
saveas(gcf, filename_3);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M = [0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
%      0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
%      0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
%      0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0;
%      0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
%      0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
%      0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
%      1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
%      0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0];
M = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     ];
S = coded_image_fig;
Shat = conv2(S, M, 'same');
Im = S;
MASK = M;
IteNum = 30;
for k = 1:IteNum
    Ik = conv2(Shat, MASK, 'same');
    ratio = Im./Ik;
    Sd = conv2(ratio, MASK, 'same');
    Shat = Shat.*Sd;
%     rmse(k) = sqrt(sum(sum((Ik/sum(Ik(:))-I/sum(I(:))).^2))/length(I));
%     if mod(k, n/10) == 0
%         disp(['iteration processing: ', int2str(k), '%']);
%     end
end

% 使用imagesc显示矩阵
figure;
imagesc(Shat);
colorbar; % 显示颜色条
axis equal; % 保证x和y轴的刻度一致
xlim([0.5, 16.5])
ylim([0.5, 16.5])
xlabel('X', 'FontName', 'Times New Roman');
ylabel('Y', 'FontName', 'Times New Roman');
colormap(gca, slanCM(167))
title('Decoded Image', 'FontName', 'Times New Roman');
filename_1 = fullfile(foldersavePath, data_name + '_decoded_image_' + '.png');
filename_2 = fullfile(foldersavePath, data_name + '_decoded_image_' + '.fig');
filename_3 = fullfile(foldersavePath, data_name + '_decoded_image_' + '.tif');
set(gca, 'FontName', 'Times New Roman')
saveas(gcf, filename_1);
saveas(gcf, filename_2);
saveas(gcf, filename_3);

%%
%高度图
figure;
surf(Shat);
% 添加轴标签
xlim([1, 13])
ylim([1, 13])
xlabel('X', 'FontName', 'Times New Roman');
ylabel('Y', 'FontName', 'Times New Roman');
zlabel('Count', 'FontName', 'Times New Roman');
colormap(gca, slanCM(167))

% 添加标题
title('Height Map of Decoded Image', 'FontName', 'Times New Roman');

% 调整视角以更好地观察图形
view(3); % 设置三维视图

%计算信噪比
max_count = max(Shat(:));
[maxValInCols, rowIndices] = max(Shat); % 每列的最大值及其行索引
[maxVal, colIndex] = max(maxValInCols); % 整个矩阵的最大值及其列索引
rowIndex = rowIndices(colIndex); % 最大值的行索引

% 最大值的位置索引
maxValueIndex = [rowIndex, colIndex];

Shat_copy = Shat; % 复制原始矩阵到新变量B
Shat_copy(rowIndex, colIndex) = NaN; % 在复制的矩阵中将最大值替换为NaN
meanValue = mean(Shat_copy(:), 'omitnan'); % 计算除最大值外的平均值，忽略NaN

SNR = max_count / meanValue;

x = 10;
y = 10;
z = 0.5*max_count;
text(x, y, z, sprintf('SNR = %.2f', SNR), 'FontName', 'Times New Roman', 'FontSize', 16); % 标注数据点
filename_1 = fullfile(foldersavePath, data_name + '_3D_decoded_image_' + '.png');
filename_2 = fullfile(foldersavePath, data_name + '_3D_decoded_image_' + '.fig');
filename_3 = fullfile(foldersavePath, data_name + '_3D_decoded_image_' + '.tif');
set(gca, 'FontName', 'Times New Roman');
saveas(gcf, filename_1);
saveas(gcf, filename_2);
saveas(gcf, filename_3);