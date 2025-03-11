
import argparse, os

parser = argparse.ArgumentParser(description='combine two one_script output files into one file')
parser.add_argument('--in1', default='[none listed]', help='the first file')
parser.add_argument('--in2', default='[none listed]', help='the second file')
parser.add_argument('--out', default='[none listed]', help='what you want to call the output file')
args = parser.parse_args()

print ('\n########################################')
print ('Preparing to combine:', args.in1, 'and', args.in2, 'to make', args.out, '...')
	
output1 = []
output2 = []
tokens2 = []

blank_incomplete = 0
duplicate = 0

with open(args.in2) as f:
	lines2 = f.readlines()

if '\x00' in lines2[0]:
	args.in2_utf8 = args.in2[:-4]+'_utf-8.csv'
	print ('in2 is utf-16... making a utf-8 copy:', args.in2_utf8)
	os.system('iconv -f UTF-16 -t UTF-8 '+args.in2+' > '+args.in2_utf8)

	with open(args.in2_utf8) as f:
		lines2 = f.readlines()


header = lines2.pop(0)
header_list = header.split(',')
token_id_position = header_list.index('token_id')

for line in lines2:
	split_line = line.split(',')
	if len(split_line) < len(header_list):
		if line.strip() == '':
			print ('...skipping a blank line in the second file')
			blank_incomplete += 1
		else:
			print ('...skipping an incomplete line in the second file:', line.strip())
			blank_incomplete += 1
	else:
		token_id = split_line[token_id_position]
		tokens2.append(token_id)
		output2.append(line)
		
with open(args.in1) as f:
	lines1 = f.readlines()

if '\x00' in lines1[0]:
	args.in1_utf8 = args.in1[:-4]+'_utf-8.csv'
	print ('in1 is utf-16... making a utf-8 copy:', args.in1_utf8)
	os.system('iconv -f UTF-16 -t UTF-8 '+args.in1+' > '+args.in1_utf8)

	with open(args.in1_utf8) as f:
		lines2 = f.readlines()


for line in lines1:
	split_line = line.split(',')
	if len(split_line) > token_id_position:
		token_id = split_line[token_id_position]
		if token_id in tokens2:
			print ('...skipping token', token_id, 'in the first file because it is in the second file')
			duplicate += 1
		elif len(split_line) < len(header_list):
			print ('...skipping an incomplete line in the first file:', line.strip())
			blank_incomplete += 1
		else:
			output1.append(line)

with open(args.out, 'w') as f:
	for line in output1+output2:
		f.write(line)

print ('read', args.in1, ':', len(lines1), 'lines (excluding header)')
print ('read', args.in2, ':', len(lines2)-1, 'lines (excluding header)')
print ('skipped', duplicate, 'lines and', blank_incomplete, 'blank or incomplete lines')
print ('wrote', args.out, ':', len(output1)+len(output2)-1, 'lines (excluding header)')
print ('########################################\n')


