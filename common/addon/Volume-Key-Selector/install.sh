# External Tools
chmod -R 0755 $MODPATH/common/addon/Volume-Key-Selector/tools

chooseport_legacy() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false
  while true; do
    timeout 0 $MODPATH/common/addon/Volume-Key-Selector/tools/$ARCH32/keycheck
    timeout $delay $MODPATH/common/addon/Volume-Key-Selector/tools/$ARCH32/keycheck
    local sel=$?
    if [ $sel -eq 42 ]; then
      return 0
    elif [ $sel -eq 41 ]; then
      return 1
    elif $error; then
      abort "未检测到音量键！"
    else
      error=true
      echo "未检测到音量键。请再试一次！"
    fi
  done
}

chooseport() {
  # Original idea by chainfire and ianmacd @xda-developers
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false 
  while true; do
    local count=0
    while true; do
      timeout $delay /system/bin/getevent -lqc 1 2>&1 > $TMPDIR/events &
      sleep 0.5; count=$((count + 1))
      if (`grep -q 'KEY_VOLUMEUP *DOWN' $TMPDIR/events`); then
        return 0
      elif (`grep -q 'KEY_VOLUMEDOWN *DOWN' $TMPDIR/events`); then
        return 1
      fi
      [ $count -gt 6 ] && break
    done
    if $error; then
      # abort "Volume key not detected!"
      echo "未检测到音量键。尝试按键检查方法！"
      export chooseport=chooseport_legacy VKSEL=chooseport_legacy
      chooseport_legacy $delay
      return $?
    else
      error=true
      echo "未检测到音量键。请再试一次！"
    fi
  done
}

echo "- 🌸 您是否需要修改机型型号为 Redmi Note11 4G?"
echo -e "# 按音量键上为是 音量键下为否。\n"

if chooseport 5; then
	echo "· 您的选择为: 是，正在为您设置..."
	echo "ro.product.system.brand=Redmi" >> $MODPATH/system.prop
	echo "ro.product.system.device=selene" >> $MODPATH/system.prop
	echo "ro.product.system.manufacturer=Xiaomi" >> $MODPATH/system.prop
	echo "ro.product.system.model=21121119SC" >> $MODPATH/system.prop
	echo "ro.product.system.name=selene" >> $MODPATH/system.prop
	echo "ro.product.system.marketname=Redmi Note 11 4G" >> $MODPATH/system.prop
else
	echo "· 您的选择为: 否，则跳过设置..."
fi

# Keep old variable from previous versions of this
VKSEL=chooseport
