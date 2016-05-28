#!/usr/bin/python
import numpy as np
from os import listdir

PATH = './results/'
RESULTS_FILE = 'table_results.csv'

files = listdir(PATH) # files are ordered as website_rtt_fastopenmode_cwnd
results_map = dict()

for file_name in files:
	if file_name == '.DS_Store':
		continue

	name, rtt, mode, cwnd = file_name.split('_')
	# amazon, wsj, nytimes, wikipedia
	if results_map.get(name) is None:
		results_map[name] = dict()

	# rtt - 20, 100, 200
	rtt_map = results_map[name]
	if rtt_map.get(rtt) is None:
		rtt_map[rtt] = dict()

	# mode - on, off
	mode_map = rtt_map[rtt]
	if mode_map.get(mode) is None:
		mode_map[mode] = dict()

	#init_cwnd - 3, 10, 20, 30
	cwnd_map = mode_map[mode]
	if cwnd_map.get(cwnd) is None:
		cwnd_map[cwnd] = list()

	with open(str(PATH+file_name), 'r') as f:
		for line in f:
			# assuming page download takes less than an hour
			minutes, seconds = map(float, line.strip().split(':'))
			time = (minutes*60) + seconds
			cwnd_map[cwnd].append(time)

# should not be in results folder for future runs
# hard coding keys for maintaining order in resulting csv file
with open(RESULTS_FILE, 'w') as f:
	f.write('Page, RTT, PLT: 10*mss & non-TFO (s), PLT: 10*mss & TFO (s), PLT: 50*mss & TFO (s), PLT: 100*mss & TFO (s), PLT: 500*mss & TFO (s), PLT: 1000*mss & TFO (s), PLT: 5000*mss & TFO (s), Improvement\n')
	for page_key in ['amazon']:#, 'nytimes', 'wsj', 'wikipedia']:
		page_map = results_map[page_key]
		for rtt_key in ['10', '50', '100']:
			rtt_map = page_map[rtt_key]
			# compute performance and relative improvement
			off_10 = np.mean(rtt_map['off']['10'])
			on_10 = np.mean(rtt_map['on']['10'])
			on_50 = np.mean(rtt_map['on']['50'])
			on_100 = np.mean(rtt_map['on']['100'])
			improvement = ((off_10-on_10)/off_10)*100
			# flush to file
			array = [page_key, rtt_key, str(off_10), str(on_10), str(on_50), str(on_100), "%.1f"%improvement]
			line = ','.join(map(str, array)) + '%\n'
			f.write(line)
