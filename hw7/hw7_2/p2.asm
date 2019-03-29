// Write your assembly program for Problem 2 (a) here.

//Branch Prediction
lbi r1, 0
lbi r2, 1
slt r0, r2, r1
bnez r0, .test
NOP
.test:
halt
