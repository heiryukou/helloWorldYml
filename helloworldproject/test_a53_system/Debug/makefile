#
# This file was created by Xilinx Vitis tool.
#


#
# tools
#

RM = rm -f
RMDIR = rm -rf



#
# variables
#

SDCARD_GEN = sdcard_gen
GENERATE_BIF = ::scw::generate_bif

XPFM_PATH = C:/SHI/helloworld/helloworldproject/sample_vitis_zcu106/export/sample_vitis_zcu106/sample_vitis_zcu106.xpfm
SYS_CONFIG = sample_vitis_zcu106
DOMAINS = standalone_domain
BIF_PATH = C:/SHI/helloworld/helloworldproject/test_a53_system/Debug/system.bif

SD_FILES = --elf C:/SHI/helloworld/helloworldproject/test_a53/Debug/test_a53.elf,psu_cortexa53_0

#
# primary build targets
#

package:
	-@echo Generating bif file for the system project
	generate_system_bif.bat 65228 ${XPFM_PATH} ${DOMAINS} ${BIF_PATH}
	${SDCARD_GEN} --xpfm ${XPFM_PATH} --sys_config ${SYS_CONFIG} --bif ${BIF_PATH} --no_bitstream ${SD_FILES}

clean:
	$(RMDIR) ./_sds
	${RMDIR} package
	${RM} system.bif

.PHONY: all package clean

all: package


