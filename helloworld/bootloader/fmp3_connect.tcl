#debug configurationのstandaloneでfmp.elfを接続後実施
targets -set -filter {name =~ "PSU"}
#セキュリティゲートの無効化
mwr 0xffca0038 0x1ff
after 500
targets -set -filter {name =~ "MicroBlaze PMU"}
dow pmufw.elf
con
after 500
targets -set -filter {name =~ "Cortex-A53 #0"}
dow ..//project//edit//zynqmp_fsbl//fsbl_a53.elf
con
