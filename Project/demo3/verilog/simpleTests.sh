#!/bin/sh
wsrun.pl -align  -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/inst_tests/all.list proc_hier_pbench *.v

mv summary.log ../verification/results/simple.summary.log
