import subprocess
import os

from CfgSetter import *

DEFAULT_INIT_CWND = 10

def download(site):
  subprocess.Popen('find ~/scratch/%s -type f|sed -e "s;^$HOME/scratch;http://localhost:8000;g"|xargs -n1000 /usr/bin/time -f "%%E" -o timing ~/mget/src/mget --no-cache --num-threads=6  --delete-after -q' % (site), shell=True).communicate()

def measure(site, half_rtt, fast_open, cwnd):
  subprocess.Popen('tail -n 1 timing >> ~/cs244-assign-3/results/%s_%s_%s_%s' % (site, half_rtt, fast_open, cwnd), shell=True).communicate()

def main():
  subprocess.Popen('rm -rf ~/cs244-assign-3/results/', shell=True).communicate()
  subprocess.Popen('mkdir ~/cs244-assign-3/results/', shell=True).communicate()

  CfgSetter.set_init_cr_wnd(DEFAULT_INIT_CWND)

  #repeat 4 times    
  for i in xrange(0, 4):
    for half_rtt in [10, 50, 100]:
      print "half_rtt: ", half_rtt

      #configure dummynet with half_rtt
      print "configure dummynet with %s" % (half_rtt)
      CfgSetter.configure_half_rtt(half_rtt);

      #Turn on TCP Fast Open
      print "Turn on TCP Fast Open"
      CfgSetter.turn_on_TFO();

      for window_size in [10, 50, 100]:

        print "Set cwnd: %s" % (window_size)
        CfgSetter.set_init_cr_wnd(window_size)

        #simulate 3 download samples
        print "simulate 3 download samples"
        for j in xrange(0, 3):
          for site in ['amazon', 'nytimes', 'wsj', 'wikipedia']:
            print "simulate %s" % (site)
            download(site)
            measure(site, half_rtt, 'on', window_size)

      #Reset initcwnd
      print "Set default cwnd: %s" % (DEFAULT_INIT_CWND)
      CfgSetter.set_init_cr_wnd(DEFAULT_INIT_CWND)

      #Turn off TCP Fast Open
      print "Turn off TCP Fast Open"
      CfgSetter.turn_off_TFO()

      #simulate 3 download samples
      print "simulate 3 download samples"
      for j in xrange(0, 3):
        for site in ['amazon', 'nytimes', 'wsj', 'wikipedia']:
          print "simulate %s" % (site)
          download(site)
          measure(site, half_rtt, 'off', DEFAULT_INIT_CWND)

if __name__ == '__main__':
  main()

