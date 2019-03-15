all: dump_decode_2ch_24bpp dump_decode_2ch_16bpp
	./dump_decode_2ch_16bpp ../projects/Digilent_Nexys_Video.sim/sim_1/behav/xsim/simulate.log 

clean :
	rm -f dump_decode_2ch_24bpp dump_decode_2ch_16bpp

dump_decode_2ch_16bpp: dump_decode_2ch_16bpp.c
	gcc -o dump_decode_2ch_16bpp dump_decode_2ch_16bpp.c -Wall -pedantic

dump_decode_2ch_24bpp: dump_decode_2ch_24bpp.c
	gcc -o dump_decode_2ch_24bpp dump_decode_2ch_24bpp.c -Wall -pedantic
