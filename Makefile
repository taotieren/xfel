#
# Makefile for module.
#

CROSS		?= 


AS		:= $(CROSS)gcc -x assembler-with-cpp
CC		:= $(CROSS)gcc
CXX		:= $(CROSS)g++
LD		:= $(CROSS)ld
AR		:= $(CROSS)ar
OC		:= $(CROSS)objcopy
OD		:= $(CROSS)objdump
RM		:= rm -fr


ASFLAGS		:= -g -ggdb -Wall -O3
CFLAGS		:= -g -ggdb -Wall -O3
CXXFLAGS	:= -g -ggdb -Wall -O3
LDFLAGS		:=
ARFLAGS		:= -rcs
OCFLAGS		:= -v -O binary
ODFLAGS		:=
MCFLAGS		:=

LIBDIRS		:=
LIBS 		:= `pkg-config --libs libusb-1.0`

INCDIRS		:= -I . `pkg-config --cflags libusb-1.0`
SRCDIRS		:= . chips


SFILES		:= $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.S))
CFILES		:= $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.c))
CPPFILES	:= $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.cpp))

SDEPS		:= $(patsubst %, %, $(SFILES:.S=.o.d))
CDEPS		:= $(patsubst %, %, $(CFILES:.c=.o.d))
CPPDEPS		:= $(patsubst %, %, $(CPPFILES:.cpp=.o.d))
DEPS		:= $(SDEPS) $(CDEPS) $(CPPDEPS)

SOBJS		:= $(patsubst %, %, $(SFILES:.S=.o))
COBJS		:= $(patsubst %, %, $(CFILES:.c=.o))
CPPOBJS		:= $(patsubst %, %, $(CPPFILES:.cpp=.o)) 
OBJS		:= $(SOBJS) $(COBJS) $(CPPOBJS)

OBJDIRS		:= $(patsubst %, %, $(SRCDIRS))
NAME		:= xfel
VPATH		:= $(OBJDIRS)

.PHONY:		all install clean

all : $(NAME)

$(NAME) : $(OBJS)
	@echo [LD] Linking $@
	@$(CC) $(LDFLAGS) $(LIBDIRS) -Wl,--cref,-Map=$@.map $^ -o $@ $(LIBS)

$(SOBJS) : %.o : %.S
	@echo [AS] $<
	@$(AS) $(ASFLAGS) -MD -MP -MF $@.d $(INCDIRS) -c $< -o $@

$(COBJS) : %.o : %.c
	@echo [CC] $<
	@$(CC) $(CFLAGS) -MD -MP -MF $@.d $(INCDIRS) -c $< -o $@

$(CPPOBJS) : %.o : %.cpp
	@echo [CXX] $<
	@$(CXX) $(CXXFLAGS) -MD -MP -MF $@.d $(INCDIRS) -c $< -o $@

install:
	install -d /usr/local/bin
	install -m0755 xfel /usr/local/bin

clean:
	@$(RM) $(DEPS) $(OBJS) $(NAME).map $(NAME) *~
