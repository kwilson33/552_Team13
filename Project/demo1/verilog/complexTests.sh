#!/bin/sh
wsrun.pl -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/complex_demo1/all.list proc_hier_bench *.v

mv summary.log ../summary/complex.summary.log
