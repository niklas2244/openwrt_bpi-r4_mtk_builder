#!/bin/bash

### delete old folders (if they exist) for a clean build
rm -rf openwrt
rm -rf mtk-openwrt-feeds

### clone required repos
git clone --branch openwrt-24.10 https://git.openwrt.org/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout 3a481ae21bdc504f7f0325151ee0cb4f25dfd2cd; cd -;		#toolchain: mold: add PKG_NAME to Makefile
git clone  https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
cd mtk-openwrt-feeds; git checkout 	b6a216c8bf4e540dd00b5f40c575745e781cfed8; cd -;	#Add PHYLIB_LEDS to the PHY framework
echo "b6a216c" > mtk-openwrt-feeds/autobuild/unified/feed_revision

### wireless-regdb modification - this remove all regdb wireless countries restrictions
rm -rf openwrt/package/firmware/wireless-regdb/patches/*.*
rm -rf mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/firmware/wireless-regdb/patches/*.*
\cp -r files/500-tx_power.patch mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/firmware/wireless-regdb/patches
\cp -r files/regdb.Makefile openwrt/package/firmware/wireless-regdb/Makefile

### jumbo frames support
wget https://raw.githubusercontent.com/woziwrt/bpi-r4-openwrt-builder/refs/heads/main/my_files/750-mtk-eth-add-jumbo-frame-support-mt7998.patch \
 -O openwrt/target/linux/mediatek/patches-6.6/750-mtk-eth-add-jumbo-frame-support-mt7998.patch

### original txpower fix
#wget https://raw.githubusercontent.com/woziwrt/bpi-r4-openwrt-builder/refs/heads/main/my_files/99999_tx_power_check.patch \
 #-O mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/kernel/mt76/patches/99999_tx_power_check.patch

### fix "use-tx_power-from-default-fw-if-EEPROM-contains-0"
wget https://github.com/danpawlik/mt76/commit/da5a863b4ec170d9022b777ccd13989873602c65.patch \
 -O mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/kernel/mt76/patches/9997-use-tx_power-from-default-fw-if-EEPROM-contains-0s.patch

### required & thermal zone 
wget https://raw.githubusercontent.com/woziwrt/bpi-r4-openwrt-builder/refs/heads/main/my_files/1007-wozi-arch-arm64-dts-mt7988a-add-thermal-zone.patch \
 -O mtk-openwrt-feeds/24.10/patches-base/1007-wozi-arch-arm64-dts-mt7988a-add-thermal-zone.patch

## adjust some config
sed -i 's/CONFIG_PACKAGE_perf=y/# CONFIG_PACKAGE_perf is not set/' mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/defconfig
sed -i 's/CONFIG_PACKAGE_perf=y/# CONFIG_PACKAGE_perf is not set/' mtk-openwrt-feeds/autobuild/autobuild_5.4_mac80211_release/mt7988_wifi7_mac80211_mlo/.config
sed -i 's/CONFIG_PACKAGE_perf=y/# CONFIG_PACKAGE_perf is not set/' mtk-openwrt-feeds/autobuild/autobuild_5.4_mac80211_release/mt7986_mac80211/.config

cd openwrt  
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt7988_rfb-mt7996 log_file=make

exit 0
