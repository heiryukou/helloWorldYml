#VITIツール上で実行ボタンを押してから実施(入口でブレークかかってしまうため)
after 5000
stop
dow u-boot.elf
dow bl31.elf
con
dow ..//project//libkernel//Debug//fmp.elf
# FPGA起動状態設定領域の3bit目をONにする
mwr 0x36FFFFFC 0x0008