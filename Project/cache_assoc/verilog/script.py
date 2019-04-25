def trans(a):
	if a == 'a':
		return 10
	if a == 'b':
		return 11
	if a == 'c':
		return 12
	if a == 'd':
		return 13
	if a == 'e':
		return 14
	if a == 'f':
		return 15
	return int(a)

content = open('result.txt')
f = open('result.addr', 'w')
for line in content:
	if 'Wr' in line:
		f.write('1 0 ')
	if 'Rd' in line:
		f.write('0 1 ')
	if not ('Wr' in line) and not ('Rd' in line):
		continue
	pos = line.find('Addr')
	pos = pos + 7
	num = trans(line[pos])
	pos = pos + 1
	num = num * 16 + trans(line[pos])
	pos = pos + 1
	num = num * 16 + trans(line[pos])
	pos = pos + 1
	num = num * 16 + trans(line[pos])
	f.write(str(num)+' ')
	if 'Rd' in line:
		f.write('0\n')
	if 'Wr' in line:
		pos = pos + 10	
		num = trans(line[pos])
		pos = pos + 1
		num = num * 16 + trans(line[pos])
		pos = pos + 1
		num = num * 16 + trans(line[pos])
		pos = pos + 1
		num = num * 16 + trans(line[pos])
		f.write(str(num)+'\n')
f.close()