space :=
space +=
nospaces = $(subst $(space),-,$1)

PROJECT = $(call nospaces,$(shell basename "`pwd`"))

TARGET_EXEC ?= $(PROJECT).elf

ARCH ?= arm
PLATFORM ?= stm32


BUILD_DIR ?= $(TEMP)/$(PROJECT)
SRC_DIRS ?= ./Src ./Drivers ./startup

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c -or -name *.s | grep -vF '/!')
OBJS := $(subst \,/,$(SRCS:%=$(BUILD_DIR)/%.o))
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

AS = arm-none-eabi-as
LD = arm-none-eabi-ld
CC = arm-none-eabi-gcc
OC = arm-none-eabi-objcopy
OD = arm-none-eabi-objdump
OS = arm-none-eabi-size

#CPPFLAGS ?= $(INC_FLAGS) -MMD -MP
CPPFLAGS += -Wall -Wextra
CPPFLAGS += -Wno-unused-variable -Wno-unused-parameter
CPPFLAGS += -I./Inc -I./Drivers/generalIO -I./Drivers/STM32F1xx_HAL_Driver/Inc -I./Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I./Drivers/CMSIS/Device/ST/STM32F1xx/Include -I./Drivers/CMSIS/Include -I./Drivers/graphics -I./Drivers/graphics/gui

CPPFLAGS += -DSTM32F103xB
# CPPFLAGS += -DSTM32F101x6
CPPFLAGS += -DUSE_HAL_DRIVER '-D__weak=__attribute__((weak))' '-D__packed=__attribute__((__packed__))'
#CPPFLAGS += -MMD -MP -MF $(BUILD_DIR)/$(@F).d
CPPFLAGS += -MMD -MP
#CPPFLAGS += -o .obj/$(@F)
#CPPFLAGS += -Og -ggdb


CPPFLAGS += -mcpu=cortex-m3
CPPFLAGS += -mthumb
CPPFLAGS += -g
CPPFLAGS += -O0
CPPFLAGS += -fno-common

LSCRIPT = ./ld/stm32.ld
LFLAGS += -T$(LSCRIPT)
# LFLAGS += -specs=nosys.specs -specs=nano.specs

# LDFLAGS += -L../../lib/$(PLATFORM)/$(ARCH) -L../../../../!cpp/lib/$(PLATFORM)/$(ARCH)

# all: app

$(TARGET_EXEC): $(OBJS)
	$(CC) $(OBJS) -o "$@" $(LDFLAGS)
	$(OD) -h -S "$@"  > $(BUILD_DIR)/"$@".lst


# assembly
$(BUILD_DIR)/%.s.o: %.s
	$(MKDIR_P) $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

# c source
$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# c++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@


.PHONY: clean

clean:
	$(RM) -r $(BUILD_DIR)

-include $(DEPS)

MKDIR_P ?= mkdir -p

# debugging make
print-%:
	@echo $* = $($*)
