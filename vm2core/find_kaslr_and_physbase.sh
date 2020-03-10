#!/bin/bash
# sudo apt install pcregrep
# $1 = vmlinux file, such as /usr/lib/debug/boot/vmlinux-4.15.0-88-generic 
# $2 = kernel coredump file that generated by vm2core

stext_vmlinux=0x$(nm $1 | grep _stext | cut -d' ' -f1)

#strings $2 | grep 'VMCOREINFO' -A68 -B2 > /tmp/_$2.vmcoreinfo.1
pcregrep -A65 -M 'VMCOREINFO\nOSRELEASE=' /tmp/_$2.vmcoreinfo.1 > /tmp/_$2.vmcoreinfo.2
stext_coredump=0x$(grep 'SYMBOL(_stext)=' /tmp/_$2.vmcoreinfo.2 | cut -d= -f2)
kaslr=$((stext_coredump-stext_vmlinux))
echo "kaslr = $kaslr"

phys_base=$(grep 'NUMBER(phys_base)=' /tmp/_$2.vmcoreinfo.2 | cut -d= -f2)
echo "phys_base = $phys_base"

echo "The complete crash command you likely need is:"
echo "./crash/crash $1 $2 --kaslr $kaslr -m phys_base=$phys_base"

