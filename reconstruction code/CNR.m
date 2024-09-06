clear; % 清空工作区

% matrix = zeros(16, 16);
% matrix(1,1) = 1;
% matrix(16,16) = 1;
% matrix(1,10) = 1;
% matrix(2,16) = 1;
% matrix(15,7) = 1;
% matrix(15,8) = 1;
% matrix(15,2) = 1;
% matrix(2,10) = 1;
% 
% figure;
% imagesc(matrix);
% axis equal; % 保证x和y轴的刻度一致
% xlim([0.5, 16.5])
% ylim([0.5, 16.5])
% xlabel('X', 'FontName', 'Times New Roman','FontSize',15, 'FontWeight','bold');
% ylabel('Y', 'FontName', 'Times New Roman','FontSize',15, 'FontWeight','bold');
% colormap(gca, slanCM(167))
% title('Dead Pixels', 'FontName', 'Times New Roman','FontSize',15, 'FontWeight','bold');
% filename_1 = fullfile('坏像素.png');
% set(gca, 'FontName', 'Times New Roman')
% saveas(gcf, filename_1);
% 获取当前目录下的所有.txt文件

files = dir('*.txt');

% 创建一个空矩阵，用于存储 numericValue 和 CNR_value
CNR_matrix = [];

% 遍历文件
for i = 1:length(files)
% for i = 1:20
    filename = files(i).name;
    
    % 检查文件名是否匹配要求的格式 "point_source_3mm_mask.txt"
    if startsWith(filename, 'point_source_') && contains(filename, 'mm_mask')
        % 提取文件名中的数字
        numericStr = regexp(filename, '\d+', 'match');
        numericValue = str2double(numericStr);
        
        % 读取文件中的二维数组
        coded_image_fig = load(filename);
        reduced_coded_image_fig = coded_image_fig(3:15, 3:15);
        % figure;
        % imagesc(reduced_coded_image_fig);
        % colorbar; % 显示颜色条
        % axis equal; % 保证x和y轴的刻度一致
        % xlim([0.5, 13.5])
        % ylim([0.5, 13.5])
        % xlabel('X', 'FontName', 'Times New Roman');
        % ylabel('Y', 'FontName', 'Times New Roman');
        % colormap(gca, slanCM(167))
        % title('Coded Image', 'FontName', 'Times New Roman');
        % set(gca, 'FontName', 'Times New Roman');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        M = [0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
             0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
             0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
             0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0;
             0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
             0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
             0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0;
             1 0 1 1 0 0 0 0 1 1 0 1 1 1 0 1 1 0 0 0 0 1 1 0 1;
             0 1 0 0 1 1 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 0];
        S = reduced_coded_image_fig;
        Shat = conv2(S, M, 'same');
        Im = S;
        MASK = M;
        IteNum = 5000;
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
        % figure;
        % imagesc(Shat);
        % colorbar; % 显示颜色条
        % axis equal; % 保证x和y轴的刻度一致
        % xlim([0.5, 13.5])
        % ylim([0.5, 13.5])
        % xlabel('X', 'FontName', 'Times New Roman');
        % ylabel('Y', 'FontName', 'Times New Roman');
        % colormap(gca, slanCM(167))
        % title('Decoded Image', 'FontName', 'Times New Roman');
        % set(gca, 'FontName', 'Times New Roman')
        
        % 设置要计算的前 N 个最大值
        N = 1;
        
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
        CNR_value = (topN_mean - rest_mean)/rest_std;
        disp(['CNR：', num2str(CNR_value)]);
        
        % 将 numericValue 和 CNR_value 添加到矩阵的一行中
        CNR_matrix(end+1, :) = [numericValue, CNR_value];
    end
end

% 将矩阵写入到文件中
dlmwrite('CNR_values.txt', CNR_matrix, 'delimiter', '\t');

% 清除不需要的变量
clearvars -except CNR_matrix

% % 显示读取的矩阵
% disp('原始矩阵:');
% disp(matrix);
% 
% % 设置要计算的前 N 个最大值
% N = 1;
% 
% % 找到矩阵中最大的 N 个点
% [~, indices] = maxk(matrix(:), N);
% 
% % 计算最大的 N 个点的平均值
% topN_mean = mean(matrix(indices));
% 
% % 剔除最大的 N 个点后，计算其余点的平均值和标准差
% matrix(indices) = [];
% rest_mean = mean(matrix(:));
% rest_std = std(matrix(:));
% 
% % 显示结果
% disp(['前', num2str(N), '个最大值的平均值：', num2str(topN_mean)]);
% disp(['其余点的平均值：', num2str(rest_mean)]);
% disp(['其余点的标准差：', num2str(rest_std)]);
% disp(['CNR：', num2str((topN_mean - rest_mean)/rest_std)]);