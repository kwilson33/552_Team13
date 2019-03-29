// Write your assembly program for Problem 1 (a) #3 here.

//Mem to Mem forwarding

lbi r0, 3
lbi r4, 2
st  r0, r4, 0
NOP
NOP
NOP
ld r0, r4, 0
st r0, r3, 0
halt