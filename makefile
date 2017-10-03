build:
	pawncc RUN_TESTS= SIF.inc

test: build
	sampctl exec SIF.amx
