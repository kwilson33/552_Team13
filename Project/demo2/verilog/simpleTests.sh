#!/bin/sh
wsrun.pl -list /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/testprograms/public/inst_tests/all.list proc_hier_pbench *.v

mv summary.log ../verfication/results/simple.summary.log
