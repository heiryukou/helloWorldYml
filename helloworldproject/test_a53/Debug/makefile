################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
ELFSIZE += \
test_a53.elf.size \
test_a53.bin \


# All Target
all: test_a53.elf secondary-outputs

# Tool invocations
test_a53.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: ARM v8 gcc linker'
	aarch64-none-elf-gcc -Wl,-T -Wl,../src/lscript.ld -LC:/SHI/helloworld/helloworldproject/sample_vitis_zcu106/export/sample_vitis_zcu106/sw/sample_vitis_zcu106/standalone_domain/bsplib/lib -o "test_a53.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

test_a53.elf.size: test_a53.elf
	@echo 'Invoking: ARM v8 Print Size'
	aarch64-none-elf-size test_a53.elf  |tee "test_a53.elf.size"
	@echo 'Finished building: $@'
	@echo 'Invoking: OBJCOPY'
	aarch64-none-elf-objcopy -O binary -S test_a53.elf test_a53.bin
	@echo 'Finished OBJCOPY: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(EXECUTABLES)$(OBJS)$(S_UPPER_DEPS)$(C_DEPS)$(ELFSIZE) test_a53.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE)

.PHONY: all clean dependents

-include ../makefile.targets
