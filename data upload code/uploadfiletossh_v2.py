import os
import paramiko # 导入paramiko模块
import time
# Paramiko是用python语言写的一个模块，远程连接到Linux服务器，查看上面的日志状态，批量配置远程服务器，文件上传，文件下载等
# 基于SSH用于连接远程服务器并执行相关操作（SSHClient和SFTPClinet,即一个是远程连接，一个是上传下载服务）
import keyboard
import threading

exit_flag=0
def wait_for_input(stop_event):
    global exit_flag
    while not stop_event.is_set():
        if keyboard.read_key() == "`":
            stop_event.set()
            exit_flag = 1
            # rbcp_udp.write(send_trig_addr,b'\x00')
            # time.sleep(0.2)
            print("Stopped.")
# 创建一个事件对象来控制键盘输入的线程
stop_event = threading.Event()
keyboard_thread = threading.Thread(target=wait_for_input, args=(stop_event,))
keyboard_thread.start()

# 统计local_folder中共有多少个'.dat'文件
def count_dat_files(local_folder):
    count = 0  # 初始化计数器
    for root, dirs, files in os.walk(local_folder):
        for file in files:
            if file.endswith('.dat'):
                count += 1  # 如果文件以.dat结尾，计数器加1
    return count

# 返回local_folder中最新创建的'.dat'文件
def find_newest_dat_file(folder_path):
    newest_file_name = None
    newest_file = None
    newest_time = 0
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith('.dat'):
                file_path = os.path.join(root, file)
                # 在Windows上使用os.path.getctime获取创建时间，在Unix系统上使用os.path.getmtime获取最后修改时间
                file_time = os.path.getctime(file_path) if os.name == 'nt' else os.path.getmtime(file_path)
                if file_time > newest_time:
                    newest_time = file_time
                    newest_file = file_path
                    newest_file_name = file
    return newest_file, newest_file_name

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

    interval = 10 # 每隔10秒检测一次文件数量
    existed_file_num = count_dat_files(local_folder)
    newest_file = None
    newest_file_name = None
    # for root, dirs, files in os.walk(local_folder):
    #     # os.walk是一个非常强大的方法，它能够遍历local_folder指定的目录，包括其子目录中的所有文件
    while True:
        if exit_flag == 1:
            break
        time.sleep(interval)
        if count_dat_files(local_folder) == existed_file_num + 1:
            newest_file, newest_file_name = find_newest_dat_file(local_folder)
        elif count_dat_files(local_folder) == existed_file_num + 2:
            remote_file = remote_path + '/' + newest_file_name
            try:
                sftp.stat(remote_file)
                print(f'文件 {remote_file} 已存在，跳过！'"")
            except FileNotFoundError:
                sftp.put(newest_file, remote_file)
                print(f'文件 {newest_file} 上传服务器 {remote_file}成功！')
            break

    existed_file_num = count_dat_files(local_folder)
    newest_file, newest_file_name = find_newest_dat_file(local_folder)
    remote_file = remote_path + '/' + newest_file_name
    
    while True:
        while True:
            if exit_flag==1:
                break
            total_dat_files = count_dat_files(local_folder)
            if total_dat_files > existed_file_num:
                existed_file_num = total_dat_files
                break
            time.sleep(interval)

        if exit_flag==1:
            break

        try:
            sftp.stat(remote_file)
            print(f'文件 {remote_file} 已存在，跳过！'"")
        except FileNotFoundError:
            sftp.put(newest_file, remote_file)
            print(f'文件 {newest_file} 上传服务器 {remote_file}成功！')
        newest_file, newest_file_name = find_newest_dat_file(local_folder)
        remote_file = remote_path + '/' + newest_file_name

        '''
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
        '''        
    # sftp.get('/mnt/userfile_qyh/pixelczt_data/Na22_20230703/PIXEL_CZT_Na22_1.dat', 'E:\server\PIXEL_CZT_Na22_1.dat')
  
finally:
    # 关闭SFTP客户端和SSH连接   
    sftp.close()
    ssh.close()
    stop_event.set()
    keyboard_thread.join()

end_time = time.time()  # 记录程序结束时间
print('程序耗时：{:.2f}秒'.format(end_time - start_time))  # 计算程序耗时并格式化输出