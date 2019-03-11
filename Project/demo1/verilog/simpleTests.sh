#!/bin/sh
wsrun.pl -list ../assemblyTests/inst_tests/all.list proc_hier_bench *.v
mv summary.log ../summary/simple.summary.log
