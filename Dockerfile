FROM nvcr.io/nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04 AS builder

# 配置Ubuntu国内源，使用北大镜像源
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.pku.edu.cn@g' /etc/apt/sources.list

# 安装基础组件
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# 配置pip国内源，使用清华镜像源
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

# 安装基础依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 安装Flash Attention
COPY flash_attn-2.7.4.post1+cu12torch2.6cxx11abiFALSE-cp310-cp310-linux_x86_64.whl .
RUN pip install flash_attn-2.7.4.post1+cu12torch2.6cxx11abiFALSE-cp310-cp310-linux_x86_64.whl --no-build-isolation && rm flash_attn-2.7.4.post1+cu12torch2.6cxx11abiFALSE-cp310-cp310-linux_x86_64.whl

# 第二阶段构建
FROM nvcr.io/nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

# 配置Ubuntu国内源，使用北大镜像源
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.pku.edu.cn@g' /etc/apt/sources.list

# 安装基础组件
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# 拷贝构建阶段的依赖
COPY --from=builder /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages

# 下载模型（使用ModelScope镜像）
WORKDIR /app
COPY model_download.py .
RUN python3 model_download.py

# 复制应用代码
COPY app /app

# 设置启动命令
# CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:7860", "main:app"]
CMD ["python3", "/app/main.py"]
