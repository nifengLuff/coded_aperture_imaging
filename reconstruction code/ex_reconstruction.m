clear; % 清空工作区
dateSuffix = datestr(datetime('now'), 'yyyy-mm-dd');
% 定义保存图形的文件夹路径
folderPath = './实验结果与重建/实验0128-4[470, 530]';

% 检查文件夹是否存在，如果不存在，则创建
if ~exist(folderPath, 'dir')
    mkdir(folderPath);
end

%%
% 计算每个像素的半高全宽
% peak_and_resolution = load('peak_er_depth_correction_energy_calibrated_spectrum.txt');
% FWHM = peak_and_resolution(:, 1:2);
% FWHM(:, 3) = peak_and_resolution(:, 3) .* peak_and_resolution(:, 4);
% % FWHM(226, 3) = 15;
% 
% FWHM_indices = cell(size(peak_and_resolution, 1), 3);
% for i = 1:size(peak_and_resolution, 1)
%     FWHM_indices{i, 1} = peak_and_resolution(i, 1);
%     FWHM_indices{i, 2} = peak_and_resolution(i, 2);
% end
% 
% FWHM_point_num = peak_and_resolution(:, 1:2);
% 
% %将文件中的能谱存入变量

spectrum = load('depth_correction_spectrum_calibrated0128.txt');
coded_image = spectrum(:, 1:2);

spectrum_y = spectrum(:, 4:2:2002);
spectrum_x = spectrum(:, 3:2:2002);
% deducted_spectrum_y = spectrum(:, 4:2:2002);
% background = spectrum(:, 4:2:2002);
% 
% for i = 1:size(peak_and_resolution, 1)
% 
%     each_FWHM_indices = find(spectrum_x(i, :) >= peak_and_resolution(i, 3) - ...
%         0.5*FWHM(i, 3) & spectrum_x(i, :) <= peak_and_resolution(i, 3) + ...
%         0.5*FWHM(i, 3));
%     FWHM_indices{i, 3} = each_FWHM_indices; 
%     FWHM_point_num(i, 3) = length(each_FWHM_indices); % 计算每个像素的SNIP迭代次数
% end
% 
% for i = 1:size(spectrum, 1)
%     [d, b] = SNIP(spectrum_y(i, :), FWHM_point_num(i, 3)); 
%     % d为临时存储deducted_spectrum的变量，b为临时存储background的变量
%     for j = 1:size(spectrum_y, 2)
%         deducted_spectrum_y(i, j) = d(j);
%         background(i, j) = b(j);
%     end
% end
sample_row = 21;

spectrum_y_original = spectrum(sample_row, 4:2:2002);
figure
plot(spectrum_x(sample_row, :), spectrum_y_original);
% figure
% plot(spectrum_x(sample_row, :), deducted_spectrum_y(sample_row, :));
% figure
% plot(spectrum_x(sample_row, :), background(sample_row, :));
% % FWHM_point_num(226, 3) = 10;
%%
%高斯拟合并计算峰面积

count = zeros(1, size(spectrum, 1));

%
% sigma = FWHM(:, 1:2);
% sigma(:, 3) = FWHM(:, 3) / 1.1774;
% 
% fitResults = cell(1, size(spectrum, 1));
% 
% for i = 1:size(spectrum, 1)
%     if i ~= 226 && i~= 231
%         i
%         peakPosition_x_range = find(spectrum_x(i, :) >  480 & spectrum_x(i, :) < 540);
%         [peakValue_y, peakPosition_y] = max(spectrum_y(i, peakPosition_x_range));
%         gauss_fitting_indices = find(...
%             spectrum_x(i, :) > spectrum_x(i, peakPosition_x_range(peakPosition_y)) - 3*sigma(i, 3) & ...
%             spectrum_x(i, :) < spectrum_x(i, peakPosition_x_range(peakPosition_y)) + 3*sigma(i, 3));
%         [fitResults{i}, gof] = fit(spectrum_x(i, gauss_fitting_indices)', deducted_spectrum_y(i, gauss_fitting_indices)', 'gauss1');
%     end
% end

% 绘制原始数据和拟合曲线
% figure
% sample_row = 36;
% plot(fitResults{sample_row}, spectrum_x(sample_row, :), deducted_spectrum_y(sample_row, :));
% legend('拟合曲线', '原始数据');
%%
for i = 1: 255
    for j = 3: 2: 2002
        if spectrum(i, j) > 470 && spectrum(i, j) < 530
            count(i) = count(i) + spectrum(i, j + 1);
        end
    end
end
% sumOfEvenCols = sum(spectrum(:, 4:2:2002), 2);
% coded_image(:, 3) = sumOfEvenCols;

coded_image(:, 3) = count;
% 创建一个空矩阵，大小根据x、y的最大值确定
coded_image_fig = zeros(max(coded_image(:,1)), max(coded_image(:,2)));
% 填充矩阵，其中newMatrix(:,3)包含对应的值
for i = 1:size(coded_image, 1)
    coded_image_fig(coded_image(i,1) + 1, coded_image(i,2) + 1) = coded_image(i,3);
end

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
reduced_coded_image_fig = coded_image_fig(2:14, 2:14);
figure;
imagesc(reduced_coded_image_fig);
colorbar; % 显示颜色条
axis equal; % 保证x和y轴的刻度一致
xlim([0.5, 13.5])
ylim([0.5, 13.5])
xlabel('X', 'FontName', 'Times New Roman');
ylabel('Y', 'FontName', 'Times New Roman');
colormap(gca, slanCM(167))
title('coded image');
filename_1 = fullfile(folderPath, ['ex_coded_image_' dateSuffix '.png']);
filename_2 = fullfile(folderPath, ['ex_coded_image_' dateSuffix '.tif']);
filename_3 = fullfile(folderPath, ['ex_coded_image_' dateSuffix '.fig']);
set(gca, 'FontName', 'Times New Roman')
saveas(gcf, filename_1);
saveas(gcf, filename_2);
saveas(gcf, filename_3);

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
figure;
imagesc(Shat);
% 添加颜色条
colorbar;
% 设置颜色条的范围，例如从0到1
clim([0.5*10^4 3.5*10^4]);
axis equal; % 保证x和y轴的刻度一致
xlim([0.5, 13.5])
ylim([0.5, 13.5])
xlabel('X', 'FontName', 'Times New Roman');
ylabel('Y', 'FontName', 'Times New Roman');
colormap(gca, slanCM(167))
title('decoded image');
filename_1 = fullfile(folderPath, ['ex_decoded_image_' dateSuffix '.png']);
filename_2 = fullfile(folderPath, ['ex_decoded_image_' dateSuffix '.tif']);
filename_3 = fullfile(folderPath, ['ex_decoded_image_' dateSuffix '.fig']);
set(gca, 'FontName', 'Times New Roman')
saveas(gcf, filename_1);
saveas(gcf, filename_2);
saveas(gcf, filename_3);

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
filename_1 = fullfile(folderPath, ['3D_ex_decoded_image_' dateSuffix '.png']);
filename_2 = fullfile(folderPath, ['3D_ex_decoded_image_' dateSuffix '.tif']);
filename_3 = fullfile(folderPath, ['3D_ex_decoded_image_' dateSuffix '.fig']);
set(gca, 'FontName', 'Times New Roman')
saveas(gcf, filename_1);
saveas(gcf, filename_2);
saveas(gcf, filename_3);

%% 成像热图绘制
% figure1 = figure('OuterPosition',[434 -29 1080 1080]);
% resultmax=max(max(result_norm));
% temp_result=result_norm;
% temp_result(1,16)=resultmax;
% resultmin=min(min(temp_result));
% h = heatmap(result,'FontName','Times New Roman',...
%     'CellLabelFormat','%d',...
%     'ColorLimits',[100 250],...
%     'FontSize',16);
figure
h = heatmap(Shat,'FontName','Times New Roman',...
    'CellLabelFormat','%d',...
    'ColorLimits',[1*10^4 3.5*10^4],...
    'FontSize',16);

xlabel=0:1:12;
ylabel=12:-1:0;

set(h, 'XDisplayLabels', xlabel);  % 修改 X 轴的显示标签
set(h, 'YDisplayLabels', ylabel);  % 修改 Y 轴的显示标签
% h.CellLabelColor="auto";
h.CellLabelColor="none";

% h = heatmap(result,'FontName','Times New Roman',...
%     'CellLabelFormat','%0.2f',...
%     'ColorLimits',[0 1000],...
%     'FontSize',16);
grid off
colormap(gca, slanCM(167))