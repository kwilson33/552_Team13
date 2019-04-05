#!/bin/sh
wsrun.pl -pipe -list ../verification/mytests/all.list proc_hier_pbench *.v

mv summary.log ../verification/results/mytests.summary.log
