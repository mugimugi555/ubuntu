import platform
import sys
import numpy as np

print("Python は正常に動作しています！")
print(f"OS: {platform.system()} {platform.release()}")
print(f"Python バージョン: {sys.version}")
print(f"NumPy バージョン: {np.__version__}")
