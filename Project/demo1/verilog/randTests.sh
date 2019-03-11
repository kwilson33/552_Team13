#!/bin/sh

wsrun.pl -list ../assemblyTests/rand_simple/all.list proc_hier_bench *.v
mv summary.log ../summary/rand_simple.summary.log

wsrun.pl -list ../assemblyTests/rand_ctrl/all.list proc_hier_bench *.v
mv summary.log ../summary/rand_ctrl.summary.log

wsrun.pl -list ../assemblyTests/rand_complex/all.list proc_hier_bench *.v 
mv summary.log ../summary/rand_complex.summary.log

wsrun.pl -list ../assemblyTests/rand_mem/all.list proc_hier_bench *.v 
mv summary.log ../summary/rand_mem.summary.log
