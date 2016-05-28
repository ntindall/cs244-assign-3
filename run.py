import subprocess
from CfgSetter import *

def main():
	# setup dependencies
	configure('sudo ./install-dependencies.sh')
	configure('sudo ./install-mget.sh')
	configure('sudo ./install-dummynet.sh')
	configure('sudo ./install-nginx.sh')

	# we don't do this every time so reproducibility isn't affected by live changes
	#configure('./download.sh')

	configure('rm -rf ~/scratch')
	configure('cp -r scratch ~')

	# start server
	configure('./configure-nginx.sh')
	configure('sudo ./restart-nginx.sh')

	# run tests and analyze results
	configure('sudo python run-mget.py')
	configure('python analyze.py')

	# results stored in results/
	# analysis stored in table_results.csv

if __name__ == '__main__':
	main()