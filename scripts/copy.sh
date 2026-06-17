#!/bin/bash
# 镜像复制脚本，两种用法：
#   - 被 source（手动工作流）：仅提供 derive_dest()/mirror() 函数。
#   - `sh copy.sh batch`（批量工作流）：解析 images.yaml 并逐条复制。
# 需要环境变量：REGISTRY、REGISTRY_NAMESPACE。

# 推导目标镜像：参数为源镜像，返回 ${REGISTRY}/${REGISTRY_NAMESPACE}/<源镜像最后一段>
# 例：quay.io/coreos/etcd:v3.5.17 推导为 ${REGISTRY}/${REGISTRY_NAMESPACE}/etcd:v3.5.17
derive_dest() {
  printf '%s/%s/%s' "$REGISTRY" "$REGISTRY_NAMESPACE" "${1##*/}"
}

# 复制镜像：参数依次为 源镜像、目标镜像（可选）、multi_arch（可选，默认 false）。
# 目标镜像为空时自动推导。
# multi_arch=true -> 全部架构（--all）；
#                    其他（false / 留空）-> 仅复制运行 runner 的架构（skopeo 默认行为，ubuntu-24.04 即 linux/amd64）。
mirror() {
  src="$1"
  dest="$2"
  multi_arch="$3"
  [ -z "$dest" ] && dest="$(derive_dest "$src")"
  if [ "$multi_arch" = "true" ]; then
    echo "Copying $src to $dest (all archs)"
    skopeo copy --all "docker://$src" "docker://$dest"
  else
    echo "Copying $src to $dest (single arch)"
    skopeo copy "docker://$src" "docker://$dest"
  fi
  echo "Copied $src to $dest"
}

# 批量模式：读取 images.yaml（.src、可选 .dest、可选 .multi_arch；multi_arch 默认 false）。
if [ "$1" = "batch" ]; then
  set -ex
  yq '.images[] | .src + "|" + (.dest // "") + "|" + ((.multi_arch == true) | tostring)' images.yaml |
    while IFS='|' read -r src dest multi_arch; do
      mirror "$src" "$dest" "$multi_arch"
    done
fi
