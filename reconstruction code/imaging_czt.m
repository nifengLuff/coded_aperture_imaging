%date:20230718  by qyh
% for root file of imaging_by_raw_spect

clear cell_data data cell_data result
% 打开文本文件进行读取
% file_path = 'D:\PIXEL_CZT\2022_PIXELCZT_FEB\11_matlab\CSNS_activate\Na_efficiency\';
 file_path = 'D:\PIXEL_CZT\2022_PIXELCZT_FEB\11_matlab\CSNS_activate\feb2\20231130\feb2_ni_2\';
% file_name='imaging_raw_spectrum.txt';
file_name='imaging_energywindow_490to530keV_raw_spectrum.txt';
open_file=strcat(file_path,file_name);

file_id = fopen(open_file, 'r');

% 读取文件内容并关闭文件
cell_data = textscan(file_id, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f', 'Delimiter', '\t', 'HeaderLines', 0);

%cell_data = textscan(file_id, '%f', 'Delimiter', '\t', 'HeaderLines', 0);

fclose(file_id);

% 将数据转换为 16x16 的数组并打印
data = cell2mat(cell_data);
result = reshape(data, [16, 16])
%%
result = result./eff_ratio;
figure
h = heatmap(result_norm,'FontName','Times New Roman',...
    'CellLabelFormat','%d',...
    'ColorLimits',[1800 2300],...
    'FontSize',16);
%% 成像热图绘制
figure1 = figure('OuterPosition',[434 -29 1080 1080]);
resultmax=max(max(result));
temp_result=result;
temp_result(1,16)=resultmax;
resultmin=min(min(temp_result));
% h = heatmap(result,'FontName','Times New Roman',...
%     'CellLabelFormat','%d',...
%     'ColorLimits',[100 250],...
%     'FontSize',16);
h = heatmap(result,'FontName','Times New Roman',...
    'CellLabelFormat','%d',...
    'ColorLimits',[resultmin*0.9 7000],...
    'FontSize',16);

xlabel=0:1:15;
ylabel=15:-1:0;

set(h, 'XDisplayLabels', xlabel);  % 修改 X 轴的显示标签
set(h, 'YDisplayLabels', ylabel);  % 修改 Y 轴的显示标签
 % h.CellLabelColor="auto";
% h.CellLabelColor="none";

% h = heatmap(result,'FontName','Times New Roman',...
%     'CellLabelFormat','%0.2f',...
%     'ColorLimits',[0 1000],...
%     'FontSize',16);

colormap(gca, slanCM(167))


grid off
%% 成像热图绘制
figure1 = figure('OuterPosition',[434 -29 1080 1080]);
resultmax=max(max(result_norm));
temp_result=result_norm;
temp_result(1,16)=resultmax;
resultmin=min(min(temp_result));
% h = heatmap(result,'FontName','Times New Roman',...
%     'CellLabelFormat','%d',...
%     'ColorLimits',[100 250],...
%     'FontSize',16);
h = heatmap(result_norm,'FontName','Times New Roman',...
    'CellLabelFormat','%d',...
    'ColorLimits',[result_norm*0.9 7000],...
    'FontSize',16);

xlabel=0:1:15;
ylabel=15:-1:0;

set(h, 'XDisplayLabels', xlabel);  % 修改 X 轴的显示标签
set(h, 'YDisplayLabels', ylabel);  % 修改 Y 轴的显示标签
 % h.CellLabelColor="auto";
% h.CellLabelColor="none";

% h = heatmap(result,'FontName','Times New Roman',...
%     'CellLabelFormat','%0.2f',...
%     'ColorLimits',[0 1000],...
%     'FontSize',16);

colormap(gca, slanCM(167))


grid off
%% save fig and emf file
folderName = '.\CSNS202311\20231112\';
% folderName=file_path;
if exist(folderName, 'dir') == 0
    mkdir(folderName);
    disp('文件夹已创建');
else
    disp('文件夹已存在');
end

file_name='imaging_raw_spectrum20231113_312_360';
filesavename1=file_name+" "+'.fig';
filesavename2=file_name+" "+'.tif';
saveas(gcf,fullfile(folderName,filesavename1));
saveas(gcf,fullfile(folderName,filesavename2));
%%  SNR cal

back_ground=[];
for p_x=1:16
    for p_y=1:16
        if(p_y<=11 && p_y>=7 && p_x>=8 && p_x<=12)
            continue;
        else
            if (result(p_x,p_y)<300)
                continue;
            else
                back_ground=[back_ground,result(p_x,p_y)];
            end
        end
    end
end


result_max_value=max(result(:));
back_ground_mean=mean(back_ground);
back_ground_std=std(back_ground);

SNR=(result_max_value-back_ground_mean)/back_ground_std;


%% 能量分辨率热图绘制

figure1 = figure('OuterPosition',[434 -29 1080 1080]);

result_resoluton=result*100;

h = heatmap(result_resoluton,'FontName','Times New Roman',...
    'CellLabelFormat','%0.2f',...
    'ColorLimits',[0 10],...
    'FontSize',16);

xlabel=0:1:15;
ylabel=15:-1:0;

set(h, 'XDisplayLabels', xlabel);  % 修改 X 轴的显示标签
set(h, 'YDisplayLabels', ylabel);  % 修改 Y 轴的显示标签


% h = heatmap(result,'FontName','Times New Roman',...
%     'CellLabelFormat','%0.2f',...
%     'ColorLimits',[0 1000],...
%     'FontSize',16);

colormap(gca, slanCM(167))

grid off
%% bar3 plot
figure
b=bar3(result);

% colormap("cool")
% colorbar

xlim([0, 17])
ylim([0,17])
xticks(0:1:16)
yticks(0:1:16)
ylabel1=[15:-1:0];
% 添加横坐标标题
xlabel('pixel-x');

% 添加纵坐标标题
ylabel('pixel-y');

yticklabels(ylabel1);

% ylabel('pixel-y',VerticalAlignment','middle');% 设置Y标签居中对齐
zlabel('counts');

for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end

set(gca, 'FontName', 'Arial', 'FontSize', 10,'FontWeight', 'bold');
grid off

colormap(gca, slanCM(167))
% 设置colorbar的范围
clim([0, 15000])

% 添加颜色条

colorbar

%% stair 绘制

X_data=0:1:length(data)-1;

figure
 stairs(X_data,data,'-o','Color',[0.1 0.5 0.9],'LineWidth',1.5)
xlim([0 255])

xticks(0:10:255);
xlabel('CH\_ID');
ylabel("Counts");


% 设置 X 轴和 Y 轴的字体、字号和加粗属性
ax = gca; % 获取当前坐标轴对象
ax.FontName = 'Arial'; % 设置字体为 Arial
ax.FontSize = 12; % 设置字号为 12
ax.FontWeight = 'bold'; % 设置加粗属性为粗体
%% save fig and emf file
folderName = '.\ASIC_imaging_20230915';
% folderName=file_path;
if exist(folderName, 'dir') == 0
    mkdir(folderName);
    disp('文件夹已创建');
else
    disp('文件夹已存在');
end

file_name='\Cs_spectrum_anode2_entries_20230920';
filesavename1=file_name+" "+'.fig';
filesavename2=file_name+" "+'.tif';
saveas(gcf,fullfile(folderName,filesavename1));
saveas(gcf,fullfile(folderName,filesavename2));
%%  mesh 函数

x=[0:1:15];
y=[0:1:15];

figure
surf(x,y,result)

shading interp
grid off

%%  normalization 



result_noralization=zeros(16,16);
for pixel_x=1:16
    for pixel_y=1:16
        if(pixel_x==16) && (pixel_y==1) 
            continue;
        else
            result_noralization(pixel_x,pixel_y)=result(pixel_x,pixel_y)/pixel_counts_normalization(pixel_x,pixel_y);
        end
    end
end

pixel_counts_normalization_max_value=max(result_noralization(:));

result_noralization_new=result_noralization/pixel_counts_normalization_max_value;


figure1 = figure('OuterPosition',[434 -29 1080 1080]);

h = heatmap(result_noralization_new,'FontName','Times New Roman',...
    'CellLabelFormat','%0.2f',...
    'ColorLimits',[0 1],...
    'FontSize',16);

xlabel=0:1:15;
ylabel=15:-1:0;

set(h, 'XDisplayLabels', xlabel);  % 修改 X 轴的显示标签
set(h, 'YDisplayLabels', ylabel);  % 修改 Y 轴的显示标签


h.CellLabelColor="none";

% h = heatmap(result,'FontName','Times New Roman',...
%     'CellLabelFormat','%0.2f',...
%     'ColorLimits',[0 1000],...
%     'FontSize',16);

colormap(gca, slanCM(167))


grid off





%%
back_ground=[];
for p_x=1:16
    for p_y=1:16
        if(p_y<=9 && p_y>=6 && p_x>=9 && p_x<=11) 
            continue;
        else
            back_ground=[back_ground,result_noralization_new(p_x,p_y)];
        end
    end
end
         

result_max_value=max(result_noralization_new(:));
back_ground_mean=mean(back_ground);
back_ground_std=std(back_ground);

SNR=(result_max_value-back_ground_mean)/back_ground_std;
%%
max_counts=max(max(result));
eff_ratio=result/max_counts;
figure
h = heatmap(eff_ratio);