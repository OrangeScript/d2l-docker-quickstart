# 📘 Docker + PyTorch + D2L（李沐）学习环境

本仓库用于在 **Windows（Docker Desktop）** 下，快速搭建一个**隔离、可复现、可持久化**的《动手学深度学习（D2L）》PyTorch 学习环境。

目标：

* ✅ 不污染本机 Python / Conda
* ✅ 代码文件可直接保存在 Windows 上
* ✅ 容器只负责“环境”，文件不丢不乱
* ✅ 完全按李沐官方教材目录结构使用

---

## 🧱 技术栈

* Docker / Docker Compose
* 基础镜像：`pytorch/pytorch:1.12.0-cuda11.3-cudnn8-runtime`
* PyTorch 1.12
* D2L（中文）Notebook
* Jupyter Notebook

> ⚠️ 本方案**不使用 conda**，不额外安装 PyTorch（镜像已自带）

---

## 📁 推荐目录结构（Windows 主机）

```text
project-root/
├── docker-compose.yml
├── Dockerfile
├── d2l-zh.zip            # 李沐教材压缩包（手动下载）
├── d2l-zh/               # 解压后目录
│   └── pytorch/          # 教材 notebook 所在目录
```

---

## 🐳 Dockerfile（环境镜像）

> 只负责「环境」，**不启动 Jupyter**

```dockerfile
FROM pytorch/pytorch:1.12.0-cuda11.3-cudnn8-runtime

WORKDIR /workspace

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    d2l==0.17.6 \
    jupyter

CMD ["bash"]
```

构建镜像：

```bash
docker build -t d2l-pytorch .
```

---

## 🧩 docker-compose.yml（推荐）

```yaml
services:
  d2l:
    image: d2l-pytorch
    ports:
      - "8888:8888"
    volumes:
      - ./:/workspace
    tty: true
```

说明：

* `./`（Windows 当前目录） → `/workspace`（容器）
* **不会覆盖容器里的子目录结构**

---

## ▶️ 启动方式

```bash
docker compose up -d
docker exec -it d2l bash
```

进入容器后：

```bash
cd /workspace
ls
```

你看到的就是 **Windows 上的文件**。

---

## 📦 下载并解压 D2L 教材（严格按官方写法）

在容器或 Windows 任意一侧执行（只需一次）：

```bash
mkdir d2l-zh
cd d2l-zh
curl https://zh-v2.d2l.ai/d2l-zh-2.0.0.zip -o d2l-zh.zip
unzip d2l-zh.zip
rm d2l-zh.zip
cd pytorch
```

> ⚠️ 解压后目录名就是 `d2l-zh/`，**不是** `d2l-zh-2.0.0`

---

## 🚀 启动 Jupyter Notebook

```bash
cd /workspace/d2l-zh/pytorch
jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root
```

浏览器访问：

```
http://localhost:8888
```

---

## 🧠 关键设计原则（非常重要）

### 1️⃣ 容器 = 环境

* Python / PyTorch / 依赖都在容器里
* 可随时删除、重建

### 2️⃣ Volume = 文件

* Notebook 文件 **只存在于 Windows**
* 不会因容器删除而丢失

### 3️⃣ Volume 会「覆盖」容器目录

```text
Windows 目录
↓（挂载）
容器目录（原内容直接消失）
```

因此：

* ❌ 不要把 volume 挂到已有教材代码的深层目录
* ✅ 统一挂到 `/workspace`

---

## ❌ 常见坑总结

| 问题                              | 原因              |
| ------------------------------- | --------------- |
| `cd: No such file or directory` | volume 覆盖了容器原目录 |
| 文件重复                            | 多次 unzip 到同一目录  |
| 容器里文件一启动就没                      | volume 挂载位置不对   |
| 为什么还要 pip install torch         | **不需要**，镜像已自带   |

---

## ✅ 适合人群

* 深度学习初学者
* 想严格按《动手学深度学习》走
* Windows 用户 + Docker Desktop
* 不想折腾 conda / Python 环境

---

## 📌 一句话总结

> **Docker 只负责环境，Windows 只负责代码，volume 负责连接。**

如果你能记住这句话，Docker 就不会再折磨你了。
