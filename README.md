Welcome to my home lab

# Setup
```bash
talhelper gensecret > talsecret.sops.yaml
sops -e -i talsecret.sops.yaml
talhelper genconfig
```

# Notes
## Ceph
- Instead of using the Ceph toolbox, use the [Krew](https://krew.sigs.k8s.io/) rook-ceph plugin. Then for example run:
```bash
k rook-ceph ceph status
```