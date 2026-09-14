BUILD_DIR ?= ../results/firmware
CROSS_COMPILE ?= riscv64-unknown-elf-
CC := $(CROSS_COMPILE)gcc
OBJCOPY := $(CROSS_COMPILE)objcopy
OBJDUMP := $(CROSS_COMPILE)objdump

CFLAGS := -march=rv32imc -mabi=ilp32 -nostdlib -nostartfiles -ffreestanding \
	-Wall -Wextra -Werror -Wl,--build-id=none -T link.ld

.PHONY: all clean
all: $(BUILD_DIR)/chipus_smoke.hex $(BUILD_DIR)/chipus_smoke.dis

$(BUILD_DIR):
	mkdir -p "$@"

$(BUILD_DIR)/chipus_smoke.elf: smoke.S link.ld | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o "$@" smoke.S

$(BUILD_DIR)/chipus_smoke.bin: $(BUILD_DIR)/chipus_smoke.elf
	$(OBJCOPY) -O binary "$<" "$@"

$(BUILD_DIR)/chipus_smoke.hex: $(BUILD_DIR)/chipus_smoke.elf
	$(OBJCOPY) --change-addresses=-0x10000000 -O verilog --verilog-data-width=4 "$<" "$@"

$(BUILD_DIR)/chipus_smoke.dis: $(BUILD_DIR)/chipus_smoke.elf
	$(OBJDUMP) -d "$<" > "$@"

clean:
	$(RM) -r "$(BUILD_DIR)"
