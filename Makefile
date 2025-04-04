.PHONY: all help doc generate sopc-syn map fit asm time power program clean

PROJECT = fpga_galaga

QUARTUS_GENERATED = db/ incremental_db/ output_files/ *.qpf *.qdf
QSYS_GENERATED = soc/ .qsys_edit/ *.sopcinfo

all: generate program download

help:
	@echo "Usage: make [target] ..."
	@echo "(Phony) Targets:"
	@echo "  generate		qsys-generate, quartus_{map,fit,asm}"
	@echo "  program		quartus_pgm"
	@echo "  clean"

doc: doc/fpga_galaga.pdf

doc/fpga_galaga.pdf:
	latexmk -pdf -outdir=doc/ doc/fpga_galaga.tex

generate: sopc-syn map fit asm

# Qsys synthesis recipe
sopc-syn:
	qsys-generate -syn soc.qsys

# Quartus synthesis recipes
map:
	quartus_map --lib_path=../inc --write_settings_files=off $(PROJECT)

fit:
	quartus_fit --write_settings_files=off $(PROJECT)

asm:
	quartus_asm --write_settings_files=off $(PROJECT)

time:
	quartus_sta $(PROJECT)

power:
	quartus_pow $(PROJECT)

# Quartus program recipe
program:
	quartus_pgm -m jtag -o "p;output_files/$(PROJECT).sof"

clean:
	@rm -rf $(QUARTUS_GENERATED) $(QSYS_GENERATED)
	@(cd doc/ && latexmk -C -quiet) > /dev/null
