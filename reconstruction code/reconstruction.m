clear all
% 指定路径
path = 'D:\code\JCF_matlab\result_download\G4_pinhole_ori'; % 替换为实际的路径

% 获取指定路径下的所有txt文件
file_list = dir(fullfile(path, '*.txt'));

% 逐个读取txt文件并创建变量
for i = 1:length(file_list)
    filename = file_list(i).name; % 获取文件名
    if ~endsWith(filename, 'count.txt') % 判断文件名是否以'count'结尾
        disp(['文件 ', filename, ' 不以"count"结尾，跳过']);
        continue; % 跳过该文件
    end
    % if ~endsWith(filename, 'count.txt') % 判断文件名是否以'count'结尾
    %     disp(['文件 ', filename, ' 不以"count"结尾，跳过']);
    %     continue; % 跳过该文件
    % end

    % 使用textscan函数读取文件中的数字
    pixel = textscan(filename, '%f'); % 读取文件中的数字并存储在cell数组中
    file_path = fullfile(path, filename); % 构造文件的完整路径

    % 读取txt文件
    data = load(file_path); % 假设txt文件中存储的是数值数据

    % 创建变量
    if length(filename)==35
        var_name = genvarname(filename(1:7));
    elseif length(filename)==36
        var_name = genvarname(filename(1:8));
    elseif length(filename)==37
        var_name = genvarname(filename(1:9));
    else
        var_name = genvarname(filename(1:10));
    end
    %var_name = genvarname(['data_', num2str(i)]); % 生成变量名
    eval([var_name ' = data;']); % 创建变量并赋值，eval 函数用于执行字符串中的 MATLAB 表达式

    disp(['已创建变量：', var_name]);
end

%% 将像素0，0调整到矩阵1，1
c_matrix = [];
c_tem2=zeros(16,16);
for i = 1:1:16
    for j = 1:1:16
        var_name = ['x_', num2str(i-1),'_y_',num2str(j-1)];
        c_temp1=eval(var_name);
        for j=1:16
            c_tem2(j,:)=c_temp1(17-j,:);
        end
        eval([var_name ' = c_tem2;']);
        c=reshape(c_tem2,[],1);
        c_matrix=[c_matrix,c];
    end
end
A=c_matrix;
% disp(c_matrix);
figure1 = figure('OuterPosition',[434 -29 1080 1080]);
h = heatmap(A,'FontName','Times New Roman',...
    'CellLabelFormat','%0.1f',...
    'FontSize',16);
colormap(gca, slanCM(167))
grid off
%%  输入数据调整
result=original_result;
data_re=zeros(16,16);
for j=1:16
     data_re(j,:)=result(17-j,:);
end
A_inv = inv(A);
data_re(2,15)=(data_re(1,15)+data_re(3,15)+data_re(2,14)+data_re(2,16))/4;
data_re(16,16)=(data_re(16,15)+data_re(15,16)+data_re(15,15))/3;
data_re(16,2)=(data_re(16,1)+data_re(16,3)+data_re(15,1))/3;
data_re(7,11)=580;
x=data_re;
%% 矩阵的逆求解
x=x_4_y_2;
% x=result;
x_re=reshape(x,[],1);
b=A\x_re.*4*10^11;
b1_h=reshape(b, 16, 16);
figure1 = figure('OuterPosition',[434 -29 1080 1080]);
h = heatmap(x,'FontName','Times New Roman',...
    'FontSize',16);
xlabel=0:1:15;
ylabel=0:1:15;
set(h, 'XDisplayLabels', xlabel);  % 修改 X 轴的显示标签
set(h, 'YDisplayLabels', ylabel);  % 修改 Y 轴的显示标签
colormap(gca, slanCM(167))
grid off

% resultmax=max(max(b1_h));
% temp_result=b1_h;
% temp_result(1,16)=resultmax;
% resultmin=min(min(temp_result));
figure2 = figure('OuterPosition',[434 -29 1080 1080]);
h = heatmap(b1_h,'FontName','Times New Roman',...
    'CellLabelColor','none',...
    'ColorLimits',[0*10^10 20*10^10],...
    'FontSize',16);
xlabel=0:1:15;
ylabel=0:1:15;
set(h, 'XDisplayLabels', xlabel);  % 修改 X 轴的显示标签
set(h, 'YDisplayLabels', ylabel);  % 修改 Y 轴的显示标签
colormap(gca, slanCM(167))
grid off
%% art iteration
X0=zeros(256,1);
e0=1E-6;
b=reshape(data_re, [], 1);
[ X, k ] = ART_0( A, b, X0, e0)
X_h=reshape(X, 16, 16)*10^11*4;
b1_h=reshape(b, 16, 16);

figure1 = figure('OuterPosition',[434 -29 1080 1080]);
h = heatmap(b1_h,'FontName','Times New Roman',...
    'FontSize',16);
xlabel=0:1:15;
ylabel=0:1:15;
set(h, 'XDisplayLabels', xlabel);  % 修改 X 轴的显示标签
set(h, 'YDisplayLabels', ylabel);  % 修改 Y 轴的显示标签
colormap(gca, slanCM(167))
grid off

figure2 = figure('OuterPosition',[434 -29 1080 1080]);
% h = heatmap(X_h,'FontName','Times New Roman',...
%     'CellLabelColor','none',...
%     'ColorLimits',[0*10^10 20*10^10],...
%     'FontSize',16);
h = heatmap(X_h,'FontName','Times New Roman',...
    'CellLabelColor','none',...
    'FontSize',16);
xlabel=0:1:15;
ylabel=0:1:15;
set(h, 'XDisplayLabels', xlabel);  % 修改 X 轴的显示标签
set(h, 'YDisplayLabels', ylabel);  % 修改 Y 轴的显示标签
colormap(gca, slanCM(167))
grid off
%%
vector_t = reshape(original_result, [], 1);
t=c_inv*vector_t;
a=c_inv*c_matrix;
% 将一维列向量还原成 16x16 矩阵
counts_hist=matrix_16x16;
figure1 = figure('OuterPosition',[434 -29 1080 1080]);
resultmax=max(max(counts_hist));
temp_result=counts_hist;
temp_result(1,16)=resultmax;
resultmin=min(min(temp_result));
h = heatmap(counts_hist,'FontName','Times New Roman',...
    'CellLabelFormat','%0.1f',...
    'ColorLimits',[resultmin*0.9 resultmax],...
    'FontSize',16);
xlabel=0:1:15;
ylabel=15:-1:0;
set(h, 'XDisplayLabels', xlabel);  % 修改 X 轴的显示标签
set(h, 'YDisplayLabels', ylabel);  % 修改 Y 轴的显示标签
colormap(gca, slanCM(167))
grid off
%% smooth
b_smooth=imaging_smooth(data_re);
b_smooth_1=imaging_smooth(b_smooth);
figure1 = figure('OuterPosition',[434 -29 1080 1080]);
h = heatmap(A,'FontName','Times New Roman',...
    'CellLabelFormat','%0.1f',...
    'FontSize',16);
xlabel=0:1:15;
ylabel=15:-1:0;
set(h, 'XDisplayLabels', xlabel);  % 修改 X 轴的显示标签
set(h, 'YDisplayLabels', ylabel);  % 修改 Y 轴的显示标签
colormap(gca, slanCM(167))
grid off