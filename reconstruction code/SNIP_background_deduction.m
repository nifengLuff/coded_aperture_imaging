clear all
data_path = 'D:\code\JCF_matlab';
[filename,pathname] = uigetfile('.txt','获取文件路径',data_path, 'MultiSelect', 'on');
open_file = strcat(pathname,filename);
result_table = readtable(open_file);
original_result = table2array(result_table);
%%
pixel_x=8;
pixel_y=1;

target_spectrum=original_result(intersect(find(original_result(:,1)==pixel_x),find(original_result(:,2)==pixel_y)),:);
% 提取奇数列的索引
odd_cols_idx = 3:2:length(target_spectrum)-1;

% 提取偶数列的索引
even_cols_idx = 4:2:length(target_spectrum);
target_spectrum_x=target_spectrum(:,odd_cols_idx);
target_spectrum_y=target_spectrum(:,even_cols_idx);
figure
plot(target_spectrum_x,target_spectrum_y)
index = find(target_spectrum_y > 0, 1);
target_spectrum_y_new=target_spectrum_y(index:end);
target_spectrum_y_new=target_spectrum_y;
%%
v=log(log(sqrt(target_spectrum_y_new+1)+1)+1);
SNIP_y_temp=v;
w=v;
% figure
% plot(target_spectrum_x(index:end),v)
% hold on
m = 10; % 根据需要设置
for p = 1:m
    for i=p+1:length(v)-p
        t1=v(i);
        t2=(v(i-p)+v(i+p))/2;
        w(i)=min(t1,t2);
    end
end
for i=p+1:length(v)-p
    v(i)=w(i);
end

back_spectrum_y = (exp(exp(v) - 1) - 1) .^ 2 - 1;
% plot(target_spectrum_x(index:end),v)
figure
plot(target_spectrum_x,back_spectrum_y)
hold on
plot(target_spectrum_x,target_spectrum_y_new)
hold on
plot(target_spectrum_x,target_spectrum_y_new-back_spectrum_y)
%%
% figure('Position', [100, 100, 550, 400]);
figure('Position', [100, 100, 600, 400]);
plot(target_spectrum_x,[target_spectrum_y(1:index-1),target_spectrum_y_new],'LineWidth',1.5)
hold on
plot(target_spectrum_x,[target_spectrum_y(1:index-1),back_spectrum_y],'LineWidth',1.5)
hold on
plot(target_spectrum_x,[target_spectrum_y(1:index-1),target_spectrum_y_new-back_spectrum_y],'LineWidth',1.5)
% 创建 ylabel
ylabel('Counts');
xlim([0, 800]);
xticks(0:200:800);
ylim([-20, 6000]);
yticks(0:1000:6000);
% 创建 xlabel
xlabel('Energy (keV)');

% 设置其余坐标区属性
set(gca,'FontName','Times New Roman','FontSize',12,'FontWeight','bold',...
    'TickLength',[0.015 0.015]);

legend('original spectrum', 'background spectrum','background-deduction spectrum', 'Location', 'northeast', 'FontSize', 10)
legend boxoff;
%%
folderName = pathname;
% folderName=file_path;
if exist(folderName, 'dir') == 0
    mkdir(folderName);
    disp('文件夹已创建');
else
    disp('文件夹已存在');
end

file_name='SNIP_background_deduction_8_1';
filesavename1=file_name+" "+'.fig';
filesavename2=file_name+" "+'.svg';
% filesavename2=file_name+" "+'.tif';
saveas(gcf,fullfile(folderName,filesavename1));
saveas(gcf,fullfile(folderName,filesavename2));