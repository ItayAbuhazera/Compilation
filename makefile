# Variables
OCAMLC=ocamlc
OCAMLFLAGS=-g
OUTPUT=compiler.byte

# Default target
all: $(OUTPUT)

# Linking
$(OUTPUT): pc.cmo compiler.cmo
	$(OCAMLC) $(OCAMLFLAGS) -o $(OUTPUT) pc.cmo compiler.cmo

# Compilation
pc.cmo: pc.ml
	$(OCAMLC) $(OCAMLFLAGS) -c pc.ml

compiler.cmo: compiler.ml pc.cmo
	$(OCAMLC) $(OCAMLFLAGS) -c compiler.ml

# Clean
clean:
	rm -f *.cmo *.cmi $(OUTPUT)