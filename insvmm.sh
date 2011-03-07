#!/bin/bash
[ "$USER" != "root" ] && echo "需要 root 權限" && exit 1

echo -n "安裝編譯所需的套件"
sudo apt-get -y install build-essential python-libvirt python-gtk-vnc python-gnome2-desktop-dev python-urlgrabber intltool libxml2-dev libvirt-dev libgtk2.0-dev libglade2-dev libgtk-vnc-1.0-dev &>/dev/null
[ "$?" != "0" ] && echo " 失敗" && exit 1
echo " 成功"

mkdir virt &>/dev/null
cd virt

wget http://virt-manager.et.redhat.com/download/sources/virt-manager/virt-manager-0.8.6.tar.gz &>/dev/null
[ "$?" != "0" ] && echo "virt-manager 下載失敗" && exit 1
echo "virt-manager 下載成功"

wget http://virt-manager.et.redhat.com/download/sources/virtinst/virtinst-0.500.5.tar.gz &>/dev/null
[ "$?" != "0" ] && echo "virtinst 下載失敗" && exit 1
echo "virtinst 下載成功"

wget http://virt-manager.et.redhat.com/download/sources/virt-viewer/virt-viewer-0.2.0.tar.gz &>/dev/null
[ "$?" != "0" ] && echo "virt-viewer 下載失敗" && exit 1
echo "virt-viewer 下載成功"

# 安裝 virt-manager
tar xvzf virt-manager-0.8.6.tar.gz &>/dev/null
cd virt-manager-0.8.6/ &>/dev/null
./configure &>/dev/null
make &>/dev/null
make install &>/dev/null
[ "$?" != "0" ] && echo "virt-manager 安裝失敗" && exit 1
echo "virt-manager 安裝成功"

# 安裝 virtinst
cd ..
tar -xvzf virtinst-0.500.5.tar.gz &>/dev/null
cd virtinst-0.500.5/ &>/dev/null
python setup.py install &>/dev/null
[ "$?" != "0" ] && echo "virtinst 安裝失敗" && exit 1
echo "virtinst 安裝成功"

# 安裝 virt-viewer
cd ..
tar -xvzf virt-viewer-0.2.0.tar.gz &>/dev/null
cd virt-viewer-0.2.0/ 
./configure &>/dev/null
make &>/dev/null
make install &>/dev/null
[ "$?" != "0" ] && echo "virt-viewer 安裝失敗" && exit 1
echo "virt-viewer 安裝成功"

cd ..
rm -r virt &>/dev/null

exit 0




