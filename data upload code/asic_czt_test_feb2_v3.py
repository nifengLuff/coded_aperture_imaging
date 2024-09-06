# date:2023.4

# for asic system test of czt


import socket
import time
import os
# import keyboard
import threading
# import psutil
from datetime import datetime

# from user.rbcp import Rbcp
from rbcp import Rbcp
# from user.afg31252 import AFG31252

rbcp_udp = Rbcp("192.168.10.16", 4660)
print("UDP连接成功.....")

sock_tcp = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock_tcp.connect(('192.168.10.16', 24))
print("TCP连接成功.....")

RECV_BUF_SIZE = 65536
# bsize = sock_tcp.getsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF)
# print("Buffer size [Before]: %d" % bsize)
# sock_tcp.setsockopt(socket.SOL_SOCKET,socket.SO_RCVBUF,RECV_BUF_SIZE)
# bsize = sock_tcp.getsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF)
sock_tcp.setsockopt(socket.SOL_SOCKET,socket.SO_KEEPALIVE,True)
sock_tcp.ioctl(socket.SIO_KEEPALIVE_VALS,(1,60*1000,30*1000))
# print("Buffer size [after]: %d" % bsize)

#set tcp not blocking 
# sock_tcp.setblocking(False)
sock_tcp.settimeout(10) #s

feb_num=2
# send cmd
send_asic_cfg_ch_addr = 0x00002010
send_asic_cfg_ch_data_all_ch_en = b'\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF'
send_asic_cfg_ch_data_init = b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01'
send_asic_cfg_en_addr = 0x00002040
send_asic_cfg_en_data = b'\x01'

send_asic_cfg_addr0 = 0x00002008
send_asic_cfg_data0 = b'\x00'
send_asic_cfg_addr1 = 0x00002009
send_asic_cfg_data1 = b'\x15'
send_asic_cfg_addr2 = 0x0000200D
send_asic_cfg_data2 = b'\x0C'
send_asic_cfg_addr3 = 0x0000200E
send_asic_cfg_data3_high_threshold = b'\x80'
send_asic_cfg_data3_init = b'\x20'

send_cathode_trig_type_addr = 0x00001010
send_cathode_en_addr = 0x00001011
send_asic_mode_addr = 0x00002100
send_trig_addr = 0x00001001
send_cali_dac_addr = 0x00006000
send_cali_en_addr = 0x00006010
send_cali_en_data = b'\x00'
send_cali_interval_addr = 0x00006020
send_cali_smooth_div_addr = 0x00006022
send_cali_smooth_div_data = b'\x08'

send_upload_datatype_address=0x00001002
send_upload_datatype=b'\x01'

rbcp_udp.write(send_asic_mode_addr,b'\x01') #normal mode
rbcp_udp.write(send_cathode_trig_type_addr,b'\x01')
rbcp_udp.write(send_cathode_en_addr,b'\x01')
rbcp_udp.write(send_cali_en_addr,send_cali_en_data) #关闭触发
rbcp_udp.write(send_upload_datatype_address,send_upload_datatype)

rbcp_udp.write(send_asic_cfg_addr0,send_asic_cfg_data0)
rbcp_udp.write(send_asic_cfg_addr2,send_asic_cfg_data2)

#read .txt threshold file 
threshold_cfg_file=r'G:\ASIC_test\threshold_cfg\20231114\threshold_cfg_feb'+str(feb_num)+'_dpm2_3.75fC_re.dat'
threshold_cfg_list=[]
with open(threshold_cfg_file,'rb') as threshold_cfg_file_fp:
    threshold_cfg_byte = threshold_cfg_file_fp.read(1)
    while threshold_cfg_byte:
        threshold_cfg_list.append(ord(threshold_cfg_byte))
        threshold_cfg_byte = threshold_cfg_file_fp.read(1)

for ch_i in range(0,256):

    send_asic_cfg_ch_data = (int.from_bytes(send_asic_cfg_ch_data_init, byteorder='big') << ch_i).to_bytes(32, byteorder='big')
    rbcp_udp.write(send_asic_cfg_ch_addr,send_asic_cfg_ch_data)

    send_asic_cfg_data3=(threshold_cfg_list[ch_i]).to_bytes(1,byteorder='big')
    rbcp_udp.write(send_asic_cfg_addr3,send_asic_cfg_data3)
    rbcp_udp.write(send_asic_cfg_en_addr,send_asic_cfg_en_data) #每次ASIC命令需发送此命令实现FPGA的最终配置
    # print("ch:"+str(ch_i)+"\tthreshold:"+str(send_asic_cfg_data3))
    # print("threshold:")
    # print(send_asic_cfg_data3)
print("threshold cfg done")

# cali_dac_data = 0x30
# rbcp_udp.write(send_cali_interval_addr,b'\x02\x00') # s
# rbcp_udp.write(send_cali_smooth_div_addr,send_cali_smooth_div_data) #8
# send_cali_dac_data=cali_dac_data.to_bytes(1,byteorder='big')+cali_dac_data.to_bytes(1,byteorder='big')\
#                     +cali_dac_data.to_bytes(1,byteorder='big')+cali_dac_data.to_bytes(1,byteorder='big')\
#                     +cali_dac_data.to_bytes(1,byteorder='big')+cali_dac_data.to_bytes(1,byteorder='big')\
#                     +cali_dac_data.to_bytes(1,byteorder='big')+cali_dac_data.to_bytes(1,byteorder='big')
# rbcp_udp.write(send_cali_dac_addr,send_cali_dac_data)
# time.sleep(0.5)
# rbcp_udp.write(send_cali_en_addr,b'\xFF')
# print('calibration activated')
# time.sleep(0.5)


file_size=1024000*500 #每次采集文件大小 *10代表10M大小  

# Recvfile_folder = r'F:\ASIC_test\data\20230625\'+cali_amp_str+'\\'
#basic_folder = r'G:\202312_gamma_source\data\20240116\feb2_th_source_1'+'\\'
basic_folder = r'G:\202312_gamma_source\coded_aperture\20240123'+'\\'
Recvfile_folder = basic_folder
if not os.path.exists(Recvfile_folder): 
    os.makedirs(Recvfile_folder)
    print("New Folder")
else:
    print("Folder Exists")

# exit_flag=0
# def wait_for_input(stop_event):
#     global exit_flag
#     while not stop_event.is_set():
#         if keyboard.read_key() == "`":
#             stop_event.set()
#             exit_flag = 1
#             # rbcp_udp.write(send_trig_addr,b'\x00')
#             # time.sleep(0.2)
#             print("Stopped.")
# # 创建一个事件对象来控制键盘输入的线程
# stop_event = threading.Event()
# keyboard_thread = threading.Thread(target=wait_for_input, args=(stop_event,))
# keyboard_thread.start()


# 定义一个线程类
# class NetworkStatsThread(threading.Thread):
#     def __init__(self, interface_name):
#         threading.Thread.__init__(self)
#         self.interface_name = interface_name
    
#     def run(self):
#         net_interfaces = psutil.net_if_addrs()
#         for interface in net_interfaces:
#             print(interface)
#         network_interface = psutil.net_io_counters(pernic=True)[self.interface_name]
#             # 获取下载字节数和当前时间
#         bytes_received_before = network_interface.bytes_recv

#         interface_filename=basic_folder+self.interface_name+"_stats.txt"
#         with open(interface_filename, "a+") as file:
#                 file.write("bytes_received(bytes) time\n")
#         while True:
#             # 获取网络接口的信息
#             # network_interface = psutil.net_io_counters(pernic=True)[self.interface_name]
#             time.sleep(5)
#             network_interface = psutil.net_io_counters(pernic=True)[self.interface_name]
#             # 获取下载字节数和当前时间
#             bytes_received = network_interface.bytes_recv
#             current_time = datetime.now().strftime("%Y%m%d %H%M%S")
#             # 将下载字节数和当前时间写入文件
#             with open(interface_filename, "a") as file:
#                 file.write(f"{bytes_received-bytes_received_before} {current_time}\n")
#             bytes_received_before=bytes_received
#             # 等待1秒钟
            
# 创建并启动线程
# interface_name = "以太网"
# thread = NetworkStatsThread(interface_name)
# thread.start()

for file_i in range(0,500):
    Recvfile_name= Recvfile_folder+r'czt_group'+str(file_i)+r'.dat'      
    with open(Recvfile_name,'wb') as fp:
        # print('calibration activated')
        rbcp_udp.write(send_trig_addr,b'\x01') 
        print('receiving data:'+Recvfile_name)
        data_size=0
        while True:
            if data_size < file_size:
                # filedata = sock_tcp.recv(1024)
                try:
                    filedata = sock_tcp.recv(1024)
                except socket.timeout:
                    print("receive time out")
                    break
            else:
                break
            fp.write(filedata)
            data_size =data_size+len(filedata)     

            # if stop_event.is_set():
            #     break
    rbcp_udp.write(send_trig_addr,b'\x00')
    time.sleep(0.2)
#     if exit_flag==1:
#         break

# stop_event.set()
# keyboard_thread.join()
sock_tcp.close()
