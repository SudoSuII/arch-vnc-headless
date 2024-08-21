import socket
import threading

# إعداد الخادم على localhost:5900
LOCAL_HOST = '127.0.0.1'
LOCAL_PORT = 5900

# إعداد الخادم على 0.0.0.0:5900
REMOTE_HOST = '0.0.0.0'
REMOTE_PORT = 5900

def handle_client(local_socket, remote_socket):
    while True:
        data = local_socket.recv(4096)
        if len(data) == 0:
            break
        remote_socket.sendall(data)

    local_socket.close()
    remote_socket.close()

def start_proxy():
    # إعداد الخادم المحلي
    local_server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    local_server.bind((LOCAL_HOST, LOCAL_PORT))
    local_server.listen(5)
    
    print(f'Listening on {LOCAL_HOST}:{LOCAL_PORT}')

    while True:
        # قبول اتصال من العميل على localhost:5900
        local_socket, addr = local_server.accept()
        print(f'Accepted connection from {addr}')
        
        # إعداد الاتصال البعيد على 0.0.0.0:5900
        remote_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        remote_socket.connect((REMOTE_HOST, REMOTE_PORT))
        
        # بدء نقل البيانات في كلا الاتجاهين
        threading.Thread(target=handle_client, args=(local_socket, remote_socket)).start()
        threading.Thread(target=handle_client, args=(remote_socket, local_socket)).start()

if __name__ == "__main__":
    start_proxy()
