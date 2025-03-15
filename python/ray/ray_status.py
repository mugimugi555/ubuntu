import ray
import torch
import os
import psutil
import socket

# Ray に接続
ray.init(address="auto")

print("🚀 Ray クラスターヘッドノードに接続しました！")

# ✅ クラスターステータスを取得
resources = ray.available_resources()
print("\n🔹 **Ray クラスターステータス** 🔹")
for key, value in resources.items():
    print(f"  {key}: {value}")

# ✅ CUDA の情報を取得
print("\n🔹 **CUDA ステータス** 🔹")
print(f"  CUDA 利用可能: {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"  使用中の GPU: {torch.cuda.get_device_name(0)}")
    print(f"  GPU メモリ使用量: {torch.cuda.memory_allocated() / 1024**2:.2f} MB")
    print(f"  GPU メモリ総容量: {torch.cuda.get_device_properties(0).total_memory / 1024**2:.2f} MB")

# ✅ サーバーのシステム情報を取得
print("\n🔹 **サーバー情報** 🔹")
print(f"  ホスト名: {socket.gethostname()}")
print(f"  OS: {os.uname().sysname} {os.uname().release}")
print(f"  CPU コア数: {psutil.cpu_count(logical=True)}")
print(f"  総メモリ: {psutil.virtual_memory().total / 1024**3:.2f} GB")
print(f"  使用中のメモリ: {psutil.virtual_memory().used / 1024**3:.2f} GB")
print(f"  空きメモリ: {psutil.virtual_memory().available / 1024**3:.2f} GB")

print("\n✅ Ray ステータスとサーバー情報の取得が完了しました！")
