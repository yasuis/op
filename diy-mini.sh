#!/bin/bash

# 修改默认IP
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# TTYD 免登录
# sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 移除要替换的包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-argon-mod
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/themes/luci-theme-netgear
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-netdata
rm -rf feeds/luci/applications/luci-app-serverchan
rm -rf feeds/package/helloworld
rm -rf package/helloworld
rm -rf feeds/packages/lang/golang
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-plugin,xray-plugin,geoview,shadow-tls,smartdns}
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/net/daed
rm -rf feeds/luci/applications/luci-app-daed
# rm -rf feeds/packages/net/ddns-go

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加额外插件
# git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome
# git clone --depth=1 -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush package/luci-app-serverchan
# git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata
git_sparse_clone main https://github.com/Lienol/openwrt-package luci-app-filebrowser luci-app-ssr-mudb-server
git clone https://github.com/sbwml/packages_lang_golang -b 27.x feeds/packages/lang/golang

# 科学上网插件
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci
git clone https://github.com/sbwml/openwrt_helloworld package/helloworld
rm -rf package/luci-app-daede
git clone --depth=1 https://github.com/kenzok8/openwrt-daede.git package/luci-app-daede
# git clone https://github.com/QiuSimons/luci-app-dae package/dae

# 移除 daede / daed 对 vmlinux-btf 的虚拟包依赖检查
find package/ feeds/ -name "Makefile" | grep -E "daed|daede" | xargs sed -i 's/+vmlinux-btf//g'
find package/ feeds/ -name "Makefile" | grep -E "daed|daede" | xargs sed -i 's/vmlinux-btf//g'
# 启用 Linux 6.7+ 的 Netkit 驱动支持
for config_file in target/linux/x86/config-*; do
  [ -f "$config_file" ] && echo "CONFIG_NETKIT=y" >> "$config_file"
done

# Themes
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
# git clone --depth=1 https://github.com/sbwml/luci-theme-argon.git package/luci-theme-argon
# git clone --depth=1 https://github.com/sbwml/luci-app-argon-config.git package/luci-app-argon-config

# 更改 Argon 主题背景
#cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
mkdir -p files/www/luci-static/argon/background
cp -f $GITHUB_WORKSPACE/images/bg1.jpg files/www/luci-static/argon/background/bg1.jpg

# 晶晨宝盒
rm -rf package/luci-app-amlogic
git_sparse_clone main https://github.com/ophub/luci-app-amlogic luci-app-amlogic
sed -i "s|firmware_repo.*|firmware_repo 'https://github.com/yasuis/op'|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i '/cat >>.\/etc\/crontabs\/root/,/EOF/d' package/luci-app-amlogic/root/usr/sbin/openwrt-update-amlogic
sed -i '/cat >>.\/etc\/crontabs\/root/,/EOF/d' package/luci-app-amlogic/root/usr/sbin/openwrt-update-kvm
# sed -i "s|kernel_path.*|kernel_path 'https://github.com/ophub/kernel'|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|ARMv8|ARMv8_lean|g" package/luci-app-amlogic/root/etc/config/amlogic

# SmartDNS
# git clone --depth=1 -b master https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
# git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# msd_lite
git clone --depth=1 https://github.com/ximiTech/luci-app-msd_lite package/luci-app-msd_lite
git clone --depth=1 https://github.com/ximiTech/msd_lite package/msd_lite

# MosDNS
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns
git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Alist
# git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

# iStore
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci

# 在线用户
git_sparse_clone main https://github.com/haiibo/packages luci-app-onliner
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# Add autocore support for armsr-armv8
sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armsr/g' package/lean/autocore/Makefile

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by yasui/g" package/lean/default-settings/files/zzz-default-settings

# 修复 hostapd 报错
# cp -f $GITHUB_WORKSPACE/script/011-fix-mbo-modules-build.patch package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch

# 修复 armv8 设备 xfsprogs 报错
# sed -i 's/TARGET_CFLAGS.*/TARGET_CFLAGS += -DHAVE_MAP_SYNC -D_LARGEFILE64_SOURCE/g' feeds/packages/utils/xfsprogs/Makefile

# 修改 Makefile
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# fstools
# rm -rf package/system/fstools
# git clone https://github.com/sbwml/package_system_fstools -b openwrt-24.10 package/system/fstools

# util-linux
# rm -rf package/utils/util-linux
# git clone https://github.com/sbwml/package_utils_util-linux -b openwrt-24.10 package/utils/util-linux

# 调整 Docker 到 服务 菜单
sed -i 's/"admin"/"admin", "services"/g' feeds/luci/applications/luci-app-dockerman/luasrc/controller/*.lua
sed -i 's/"admin"/"admin", "services"/g; s/admin\//admin\/services\//g' feeds/luci/applications/luci-app-dockerman/luasrc/model/cbi/dockerman/*.lua
sed -i 's/admin\//admin\/services\//g' feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/*.htm
sed -i 's|admin\\|admin\\/services\\|g' feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/container.htm

# 调整 ZeroTier 到 服务 菜单
# sed -i 's/vpn/services/g; s/VPN/Services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua
# sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm

# 取消对 samba4 的菜单调整
# sed -i '/samba4/s/^/#/' package/lean/default-settings/files/zzz-default-settings

# 测试开启bbr3
# sed -i '/exit 0/i echo bbr3 > /proc/sys/net/ipv4/tcp_congestion_control' /etc/rc.local
sed -i '/exit 0/i echo bbr3 > /proc/sys/net/ipv4/tcp_congestion_control' package/base-files/files/etc/rc.local

# uhttpd关掉HTTPS
sed -i 's/^\s*list listen_https\s*/# &/g' ./package/network/services/uhttpd/files/uhttpd.config

cat >> package/kernel/linux/modules/netsupport.mk << 'EOF'

define KernelPackage/netkit
  SUBMENU:=$(NETWORK_SUPPORT_MENU)
  TITLE:=Netkit BPF device support
  KCONFIG:=CONFIG_NETKIT=y
  FILES:=$(LINUX_DIR)/drivers/net/netkit.ko
  AUTOLOAD:=$(call AutoLoad,30,netkit)
endef

$(eval $(call KernelPackage,netkit))
EOF
# 在 .config 中开启该模块
echo "CONFIG_PACKAGE_kmod-netkit=y" >> .config
sed -i 's/+kmod-fs-nfs-common-rpcsec//g' package/kernel/linux/modules/fs.mk

./scripts/feeds update -a
./scripts/feeds install -a
