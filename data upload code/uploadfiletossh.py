import os
import paramiko # 导入paramiko模块
import time

# Paramiko是用python语言写的一个模块，远程连接到Linux服务器，查看上面的日志状态，批量配置远程服务器，文件上传，文件下载等
# 基于SSH用于连接远程服务器并执行相关操作（SSHClient和SFTPClinet,即一个是远程连接，一个是上传下载服务）
import time

start_time = time.time()  # 记录程序开始时间

# SSH连接信息
hostname = '114.214.163.192'
port = 1406
username = 'qinyanghui'
private_key_path = r'E:\server\qinyanghui' # 私钥路径

# 本地文件夹路径和目标路径
# local_folder = r'E:\PIXEL_CZT_DATA\Na22_20230713'
local_folder = r'G:\PIXEL_CZT\RAW_DATA\PIXEL_CZT_Eu152_HV2000V_20230814'

# remote_path = r'/mnt/userfile_qyh/pixelczt_data/Na22_20230721' 

remote_path = r'/mnt/userfile_qyh/pixelczt_data/PIXEL_CZT_Eu152_HV2000V_20230814' 


# 创建SSH客户端
ssh = paramiko.SSHClient() #创建SSH对象
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy()) #set_missing_host_key_policy方法：选择了AutoAddPolicy，表示自动在~/.ssh/known_hosts文件中添加新主机名及其主机密钥。

try:
    # 导入私钥
    private_key = paramiko.RSAKey.from_private_key_file(private_key_path)

    # 连接服务器
    ssh.connect(hostname, port, username, pkey=private_key)

    # 创建SFTP客户端
    sftp = ssh.open_sftp()


    # 判断远程路径是否存在
    try:
        sftp.listdir(remote_path)
        print(f'远程文件夹已存在：{remote_path}')
    except FileNotFoundError:
    # 如果远程路径不存在，则创建该路径
        sftp.mkdir(remote_path)
        print(f'创建远程文件夹：{remote_path}')

    for root, dirs, files in os.walk(local_folder):
        for file in files:
            if file.endswith('.dat'):
                local_file = os.path.join(root, file)
                # remote_file = os.path.join(remote_path,file)

                remote_file = remote_path + '/' + file


                try:
                    sftp.stat(remote_file)
                    print(f'文件 {remote_file} 已存在，跳过！'"")
                except FileNotFoundError:
                    # 获取本地文件大小
                    # file_size = os.path.getsize(local_file)

                    # 开始上传文件：记录开始时间
                    # start_time = time.time()


                    sftp.put(local_file, remote_file)
                    print(f'文件 {local_file} 上传服务器 {remote_file}成功！')

                    # 上传完成：记录结束时间
                    # end_time = time.time()

                    # 计算上传所花费的时间
                    # upload_time = end_time - start_time

                    # 计算上传速度（字节/秒）
                    # upload_speed = file_size / upload_time

                    # 打印上传速度
                    # print(f'文件 {local_file} 上传速度：{upload_speed} 字节/秒')
                    # print(f'文件大小：{file_size} 字节')
                    # print(f'上传时间：{upload_time} 秒')
                    # print(f'上传速度：{upload_speed} 字节/秒')
     
    print('所有文件上传完成！')
                
    # sftp.get('/mnt/userfile_qyh/pixelczt_data/Na22_20230703/PIXEL_CZT_Na22_1.dat', 'E:\server\PIXEL_CZT_Na22_1.dat')
  
finally:
    # 关闭SFTP客户端和SSH连接
    sftp.close()
    ssh.close()


end_time = time.time()  # 记录程序结束时间
print('程序耗时：{:.2f}秒'.format(end_time - start_time))  # 计算程序耗时并格式化输出