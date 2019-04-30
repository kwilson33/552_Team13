#!/bin/sh
wsrun.pl -align -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/complex_demo1/all.list proc_hier_pbench *.v

mv summary.log ../verification/results/complex.summary.log

wsrun.pl -align -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/complex_demo2/all.list proc_hier_pbench *.v

mv summary.log ../verification/results/complex_demo2.summary.log
