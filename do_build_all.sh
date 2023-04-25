

# build type : 32r 32d 64r 64d
BT=64r

# library build type : b32 all32 b64 all64
LBT=all64

if [ -n "$1" ]; then
	BT=$1
fi
if [ -n "$2" ]; then
	LBT=$2
fi

# echo $BT
# echo $LBT
# exit 0

sh update_source.sh

# date
# sh rebuild_cross.sh $BT

date
sh rebuild_target.sh $BT

date

