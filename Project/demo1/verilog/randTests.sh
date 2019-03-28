#!/bin/sh

wsrun.pl -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_simple/all.list proc_hier_bench *.v
mv summary.log ../summary/rand_simple.summary.log

wsrun.pl -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_ctrl/all.list proc_hier_bench *.v
mv summary.log ../summary/rand_ctrl.summary.log

wsrun.pl -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_complex/all.list proc_hier_bench *.v
mv summary.log ../summary/rand_complex.summary.log

wsrun.pl -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_simple/all.list proc_hier_bench *.v
mv summary.log ../summary/rand_mem.summary.log
