SRCS=$(wildcard *.java)
OBJS=$(SRCS:.java=.class)
BIN=$(wildcard ../*_code.bin ../*_data.bin ../*_code_mem.v ../*_data_mem.v)

all: $(OBJS)
	java AsmTop --width_m_d=16

$(OBJS):%.class:%.java
	javac $<

clean:
	rm -f *.class
	rm -f $(BIN)
