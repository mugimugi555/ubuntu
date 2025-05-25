#!/bin/bash
# K20 用 ML 環境セットアップスクリプト for Ubuntu 18.04
# CUDA 10.2 + PyTorch 1.4 + TensorFlow 1.14 + OpenCV (CUDA対応)

set -e

# ------------------------------
# 1. CUDA 10.2 + cuDNN 7.6.x
# ------------------------------
echo "[1/6] Installing CUDA 10.2 & cuDNN..."

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda-repo-ubuntu1804-10-2-local_10.2.89-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1804-10-2-local_10.2.89-1_amd64.deb
sudo apt-key add /var/cuda-repo-*/7fa2af80.pub
sudo apt update
sudo apt install -y cuda

# cuDNN 7.6.x
# (NOTE: You must manually place cudnn tar file in current dir)
tar -xvf cudnn-10.2-linux-x64-v7.6.5.32.tgz
sudo cp -P cuda/include/cudnn*.h /usr/local/cuda/include
sudo cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64
sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*

# ------------------------------
# 2. PyTorch 1.4 + TorchVision 0.5
# ------------------------------
echo "[2/6] Installing PyTorch 1.4..."

conda create -n k20torch python=3.7 -y
source ~/anaconda3/etc/profile.d/conda.sh
conda activate k20torch

pip install torch==1.4.0 torchvision==0.5.0

# ------------------------------
# 3. OpenCV with CUDA build config
# ------------------------------
echo "[3/6] Writing OpenCV CMake config (CUDA enabled)..."

mkdir -p ~/opencv_cuda_build
cat <<EOF > ~/opencv_cuda_build/cmake_config.txt
-D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D WITH_CUDA=ON \
-D CUDA_ARCH_BIN=3.5 \
-D CUDA_ARCH_PTX= \
-D ENABLE_FAST_MATH=1 \
-D CUDA_FAST_MATH=1 \
-D WITH_CUBLAS=1 \
-D OPENCV_DNN_CUDA=ON \
-D BUILD_opencv_python3=ON \
-D BUILD_EXAMPLES=ON
EOF

# ------------------------------
# 4. Torch MNIST/CIFAR Sample
# ------------------------------
echo "[4/6] Writing PyTorch MNIST/CIFAR sample..."

mkdir -p ~/torch_samples
cat <<EOF > ~/torch_samples/mnist_cifar_torch14.py
import torch
import torchvision
import torchvision.transforms as transforms

transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.5,), (0.5,))
])

trainset = torchvision.datasets.MNIST(root='./data', train=True, download=True, transform=transform)
trainloader = torch.utils.data.DataLoader(trainset, batch_size=64, shuffle=True)

print("\n[✔] MNIST loaded. Starting training loop test...")
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim

class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.fc1 = nn.Linear(28*28, 128)
        self.fc2 = nn.Linear(128, 10)

    def forward(self, x):
        x = x.view(-1, 28*28)
        x = F.relu(self.fc1(x))
        return self.fc2(x)

net = Net().cuda()
criterion = nn.CrossEntropyLoss()
optimizer = optim.SGD(net.parameters(), lr=0.01)

for i, data in enumerate(trainloader):
    inputs, labels = data
    inputs, labels = inputs.cuda(), labels.cuda()
    optimizer.zero_grad()
    outputs = net(inputs)
    loss = criterion(outputs, labels)
    loss.backward()
    optimizer.step()
    print(f'[{i}] loss: {loss.item():.3f}')
    if i > 5: break
EOF

# ------------------------------
# 5. TensorFlow 1.14 install
# ------------------------------
echo "[5/6] Installing TensorFlow 1.14..."

conda create -n k20tf python=3.6 -y
conda activate k20tf
pip install tensorflow-gpu==1.14.0

# ------------------------------
# 6. TF MNIST sample code
# ------------------------------
echo "[6/6] Writing TensorFlow MNIST sample..."

mkdir -p ~/tf_samples
cat <<EOF > ~/tf_samples/mnist_tf114.py
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)

x = tf.placeholder(tf.float32, [None, 784])
W = tf.Variable(tf.zeros([784, 10]))
b = tf.Variable(tf.zeros([10]))
y = tf.nn.softmax(tf.matmul(x, W) + b)
y_ = tf.placeholder(tf.float32, [None, 10])

cross_entropy = tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(y), reduction_indices=[1]))
train_step = tf.train.GradientDescentOptimizer(0.5).minimize(cross_entropy)

sess = tf.InteractiveSession()
sess.run(tf.global_variables_initializer())

for i in range(100):
    batch_xs, batch_ys = mnist.train.next_batch(100)
    sess.run(train_step, feed_dict={x: batch_xs, y_: batch_ys})

correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
print("Test Accuracy:", sess.run(accuracy, feed_dict={x: mnist.test.images, y_: mnist.test.labels}))
EOF

# ------------------------------
# 7. OpenCV CUDA Batch Resize Sample
# ------------------------------
echo "[7/7] Writing OpenCV CUDA batch resize sample..."

mkdir -p ~/opencv_samples
cat <<EOF > ~/opencv_samples/batch_resize_cuda.py
import cv2
import os
import glob
import numpy as np

# 入出力フォルダ
INPUT_DIR = "./images"
OUTPUT_DIR = "./resized"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ファイル読み込み
image_paths = glob.glob(os.path.join(INPUT_DIR, "*.jpg"))

# CUDA初期化
resize_size = (256, 256)
for path in image_paths:
    img = cv2.imread(path)
    gpu_img = cv2.cuda_GpuMat()
    gpu_img.upload(img)
    gpu_resized = cv2.cuda.resize(gpu_img, resize_size)
    result = gpu_resized.download()
    filename = os.path.basename(path)
    cv2.imwrite(os.path.join(OUTPUT_DIR, filename), result)
    print(f"Resized: {filename}")
EOF

echo "\n🎉 Setup complete. Use conda activate k20torch or k20tf to get started."
