#!/bin/sh

wsrun.pl -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_ctrl/all.list proc_hier_pbench *.v
mv summary.log ../verification/results/rand_ctrl.summary.log

wsrun.pl -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_complex/all.list proc_hier_pbench *.v
mv summary.log ../verification/results/rand_complex.summary.log

wsrun.pl -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_idcache/all.list proc_hier_pbench *.v
mv summary.log ../verification/results/rand_idcache.summary.log

wsrun.pl -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_icache/all.list proc_hier_pbench *.v
mv summary.log ../verification/results/rand_icache.summary.log

wsrun.pl -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_ldst/all.list proc_hier_pbench *.v
mv summary.log ../verification/results/rand_ldst.summary.log

wsrun.pl -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_ldst/all.list proc_hier_pbench *.v
mv summary.log ../verification/results/rand_dcache.summary.log

wsrun.pl -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_final/all.list proc_hier_pbench *.v
mv summary.log ../verification/results/rand_final.summary.log

wsrun.pl -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_simple/all.list proc_hier_pbench *.v
mv summary.log ../verification/results/rand_simple.summary.log

wsrun.pl -pipe -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/rand_simple/all.list proc_hier_pbench *.v
mv summary.log ../verification/results/rand_mem.summary.log

