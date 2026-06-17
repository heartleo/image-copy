# Image Copy

> 使用 `GitHub Actions` 把 `docker.io`、`quay.io`、`gcr.io`、`k8s.gcr.io` 等海外仓库的容器镜像，复制到你自己的容器镜像仓库，解决国内拉取慢或失败的问题，支持任意兼容 `docker login` 的镜像服务。

## 一、前置准备（阿里云 ACR）

### 1. 开通容器镜像服务

- 注册阿里云账号（`your-username`）
- 开通「容器镜像服务」个人版（免费）
- 创建命名空间（`your-namespace`）—— 控制台「实例列表 → 个人实例 → 命名空间 → 创建命名空间」
- 设置密码（`your-password`）—— 控制台「访问凭证 → 设置固定密码」

### 2. Fork仓库并配置 Secrets

点击 `Use this template` 创建你的仓库，在 `Settings → Secrets and variables → Actions → New repository secret` 添加以下：

| Secret               | 含义           | 阿里云 ACR                         |
| -------------------- | -------------- | ---------------------------------- |
| `REGISTRY`           | 镜像仓库地址   | `registry.cn-beijing.aliyuncs.com` |
| `REGISTRY_USERNAME`  | 仓库登录用户名 | `your-username`                    |
| `REGISTRY_PASSWORD`  | 仓库登录密码   | `your-password`                    |
| `REGISTRY_NAMESPACE` | 命名空间       | `your-namespace`                   |

## 二、复制镜像

两种方式，按需选择：

| 方式     | 适用场景     | 触发方式                |
| -------- | ------------ | ----------------------- |
| **批量** | 复制多个镜像 | 提交 `images.yaml` 触发 |
| **手动** | 复制单个镜像 | 在 Actions 页手动触发   |

### 方式一：批量复制

参考 `images.yaml.example` 新建 `images.yaml`，提交后自动触发 `Copy Image` 工作流：

```yaml
images:
  - src: redis:7.2.5
  - src: quay.io/coreos/etcd:v3.5.17
    dest: <REGISTRY>/<REGISTRY_NAMESPACE>/etcd:v3.5.17
  - src: k8s.gcr.io/pause:3.2
    multi_arch: true
```

支持以下字段：

| 字段         | 必填 | 说明                |
| ------------ | ---- | ------------------- |
| `src`        | 是   | 源镜像              |
| `dest`       | 否   | 目标镜像            |
| `multi_arch` | 否   | `true` 复制全部架构 |

### 方式二：手动复制

进入 `Actions → Manual Copy Image → Run workflow`，填写表单：

| 字段         | 必填 | 说明                                                    |
| ------------ | ---- | ------------------------------------------------------- |
| `source`     | 是   | 源镜像，如 `redis:7.2.5`、`quay.io/coreos/etcd:v3.5.17` |
| `dest`       | 否   | 目标镜像                                                |
| `multi_arch` | 是   | 勾选复制全部架构                                        |

## 三、目标镜像如何确定

当 `dest` 为空时，按以下规则：

```
dest = ${REGISTRY}/${REGISTRY_NAMESPACE}/<镜像名>
```

| 源镜像                        | 目标镜像                                       |
| ----------------------------- | ---------------------------------------------- |
| `redis:7.2.5`                 | `<REGISTRY>/<REGISTRY_NAMESPACE>/redis:7.2.5`  |
| `quay.io/coreos/etcd:v3.5.17` | `<REGISTRY>/<REGISTRY_NAMESPACE>/etcd:v3.5.17` |

## 四、拉取已复制的镜像

```bash
# redis:7.2.5
docker pull <REGISTRY>/<REGISTRY_NAMESPACE>/redis:7.2.5
# quay.io/coreos/etcd:v3.5.17
docker pull <REGISTRY>/<REGISTRY_NAMESPACE>/etcd:v3.5.17
```
