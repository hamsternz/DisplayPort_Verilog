all: dump_decode_2ch
	./dump_decode_2ch ../projects/Digilent_Nexys_Video.sim/sim_1/behav/xsim/simulate.log 
dump_decode_2ch: dump_decode_2ch.c
	gcc -o dump_decode_2ch dump_decode_2ch.c -Wall -pedantic
