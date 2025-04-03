# 本地Docker部署通义千问

本仓库记录通过Docker本地部署通义千问的过程，使用的通义千问模型为 `Qwen/Qwen2.5-1.5B-Instruct-GPTQ-Int4` ，以支持一些开发过程中 API 调用之需求。

## 环境准备

部署在以下环境得到了验证：

| | |
| :---: | :---: |
| 系统 | Ubuntu 22.04 |
| 显卡 | RTX 3050 |
| 驱动版本 | 550.120 |
| 显存 | 4GB |
| CPU | 20核 |
| 内存 | 16GB |
| Docker | 28.0.4 |

你需要准备以下环境：

1. **安装Docker** ：请注意不要直接使用 `apt` 等系统的包管理器安装，而是使用官方的安装脚本，中国大陆的朋友可以通过镜像源安装，比如[北大镜像源](https://mirrors.pku.edu.cn/Help/Docker-ce)。
2. **安装NVIDIA驱动** ：确保你的显卡驱动版本与Docker兼容。你可以使用 `nvidia-smi` 命令检查驱动版本。
3. **安装 nvidia-container-toolkit** ：用于管理Docker容器的GPU资源。

> [!TIP]
> 如果你在中国大陆，你可能会遇到 DockerHub 的镜像无法拉取的问题，这是正常的现象，你可以寻找镜像源来解决，但这个工作中你不需要使用镜像源，我已经充分考虑了这个问题，所有的步骤都可以在当前（2025.4.3）的中国大陆网络环境下完成。

准备好环境之后，你可以开始部署工作了，如果你希望使用构建好的镜像，请移步[快速开始](#快速开始)，如果你希望自己构建镜像，请移步[自己构建](#自己构建)。

## 快速开始

我已经构建好了一个镜像，只要你的驱动版本能支持 CUDA 12.4 ，你就可以直接使用这个镜像。

### 拉取镜像

通过如下命令拉取镜像

```bash
docker pull crpi-dqve2dbgo42o37yv.cn-beijing.personal.cr.aliyuncs.com/yibotongxue/qwen-chat:Qwen2.5-1.5B-Instruct-GPTQ-Int4
```

镜像部署在阿里云的镜像托管平台上，在中国大陆可以直接访问。

### 启动容器

通过如下命令启动容器

```bash
docker run -d --rm --gpus all -p 7860:7860  qwen-chat
```

### 访问服务

本地可以通过 API 访问服务，具体的你可以使用POST请求访问 `/chat` 端点，比如

```bash
curl -X POST http://localhost:7860/chat 
-H "Content-Type: application/json" \
-d '{"prompt": "请解释量子力学的基本原理"}'
```

成功的响应会是类似以下的格式：

```json
{
  "response": "量子力学是描述微观粒子运动规律的理论..."
}
```

## 自己构建

你可以通过以下命令来构建镜像

```bash
docker build -t qwen-chat .
```

也可以根据需要修改 `Dockerfile` 中的内容，比如修改模型、修改 `Pytorch` 版本等。

## 注意事项

使用本镜像或者自己构建镜像时，请严格遵守中国法律法规，不得用于任何非法用途。本镜像及本仓库仅为个人学习用途。
