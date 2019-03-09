// checks jump and link
lbi r0, 0
jalr r0, 4   		//jumps to A then B then C
lbi r0, 8    		//target A
jalr r0, -6  		//target B
nop
nop
halt         		//target C
