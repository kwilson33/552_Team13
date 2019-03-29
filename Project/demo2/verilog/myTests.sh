#!/bin/sh
wsrun.pl -list ../verification/mytests/all.list proc_hier_pbench *.v

mv summary.log ../verfication/results/mytests.summary.log