# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\tmp\Vitis_ets\edt_ecu106\sample_vitis_zcu106\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\tmp\Vitis_ets\edt_ecu106\sample_vitis_zcu106\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {sample_vitis_zcu106}\
-hw {C:\tmp\Vitis_ets\edt_ecu106\edt_zcu106_wrapper.xsa}\
-proc {psu_cortexa53_0} -os {standalone} -arch {64-bit} -fsbl-target {psu_cortexa53_0} -out {C:/tmp/Vitis_ets/edt_ecu106}

platform write
platform generate -domains 
platform active {sample_vitis_zcu106}
bsp reload
bsp setlib -name xilffs -ver 4.7
bsp setlib -name xilflash -ver 4.9
bsp setlib -name xilfpga -ver 6.2
bsp removelib -name xilfpga
bsp removelib -name xilflash
bsp setlib -name xilpm -ver 4.0
bsp setlib -name xilsecure -ver 4.7
bsp write
bsp reload
catch {bsp regenerate}
platform generate
domain create -name {psu_cirtexer50} -os {standalone} -proc {psu_cortexa53_0} -arch {64-bit} -display-name {psu_cirtexer50} -desc {} -runtime {cpp}
platform generate -domains 
platform write
domain -report -json
bsp reload
bsp setlib -name xilffs -ver 4.7
bsp removelib -name xilffs
bsp setlib -name xilpm -ver 4.0
bsp setlib -name xilffs -ver 4.7
bsp setlib -name xilsecure -ver 4.7
bsp write
bsp reload
catch {bsp regenerate}
platform active {sample_vitis_zcu106}
platform generate -domains psu_cirtexer50 
platform active {sample_vitis_zcu106}
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform clean
platform clean
platform generate
