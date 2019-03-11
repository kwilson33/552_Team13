#!/bin/sh
wsrun.pl -list ../assemblyTests/complex_demo1/all.list proc_hier_bench *.v
mv summary.log ../summary/complex.summary.log
