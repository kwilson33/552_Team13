#!/bin/sh

wsrun.pl -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_simple/all.list proc_hier_pbench *.v
mv summary.log ../verfication/results/rand_simple.summary.log

wsrun.pl -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_ctrl/all.list proc_hier_pbench *.v
mv summary.log ../verfication/results/rand_ctrl.summary.log

wsrun.pl -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_complex/all.list proc_hier_pbench *.v
mv summary.log ../verfication/results/rand_complex.summary.log

wsrun.pl -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_simple/all.list proc_hier_pbench *.v
mv summary.log ../verfication/results/rand_mem.summary.log
