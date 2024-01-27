OCAMLC=ocamlc # compiler
OCAMLFLAGS=-g # flags

all: main

main: compiler.cmo pc.cmo
	$(OCAMLC) $(OCAMLFLAGS) -o main pc.cmo compiler.cmo

pc.cmo: pc.ml
	$(OCAMLC) $(OCAMLFLAGS) -c pc.ml

compiler.cmo: compiler.ml pc.cmo
	$(OCAMLC) $(OCAMLFLAGS) -c compiler.ml

clean:
	rm -f *.cmo *.cmi main

.PHONY: all clean
