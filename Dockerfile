# 官方 PyTorch 镜像（已包含 Python + torch）
FROM pytorch/pytorch:1.12.0-cuda11.3-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive

# 工作目录
WORKDIR /workspace

# 基础工具
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Python 依赖（不重复装 torch）
RUN pip install --no-cache-dir \
    torchvision==0.13.0 \
    d2l==0.17.6 \
    jupyter

# 严格按李沐官方写法下载代码
RUN mkdir d2l-zh && cd d2l-zh && \
    curl https://zh-v2.d2l.ai/d2l-zh-2.0.0.zip -o d2l-zh.zip && \
    unzip d2l-zh.zip && rm d2l-zh.zip

# ❗什么都不自动做，给你一个 shell
CMD ["bash"]
