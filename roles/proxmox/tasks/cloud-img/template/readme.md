Create a VM from a cloud Template:

# 1. create the vm
``` bash
qm create {{ cloud_image_id_prefix){{ item.id }} --bios ovmf --ciuser {{ cloud_init_user }} \
--name cloud-template-{{ item.name }} --memory 1024 --net0 virtio,bridge=vmbr0 --numa 0 --sockets 1 \
--cores 1 --ostype l26 --rng0 /dev/urandom --agent enabled=1,fstrim_cloned_disks=1 --cpu cputype={{ qemu_cpu_type }} --tags template
```
# 2. create the efi disk
``` bash
qm set {{ cloud_image_id_prefix }}{{ item.id }} --efidisk0 {{ storage_id }}:{{ cloud_image_id_prefix }}{{ item.id }}-efi
```

# 3. create the cloud-init drive
``` bash
qm set {{ cloud_image_id_prefix }}{{ item.id }} --ide2 {{ storage_id }}:cloudinit
```

# 4. create the tpm state disk
``` bash
qm set {{ cloud_image_id_prefix }}{{ item.id }} -tpmstate0 {{ storage_id }}:1,version=v2.0
```

# 5. create the vm disk
``` bash
qm set {{ cloud_image_id_prefix }}{{ item.id }} --scsihw virtio-scsi-pci \
--scsi0 {{ storage_id }}:0,import-from=/root/cloud-images/{{ item.name }}.qcow2
```