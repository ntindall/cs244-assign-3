
import subprocess

def configure(cmd):
  return subprocess.Popen(cmd, shell=True).communicate()

class CfgSetter():

  def __init__(self):
    return 0

  # @staticmethod
  # def configure(cmd):
  #   return subprocess.Popen(cmd, shell=True).communicate()

  #     The values (bitmap) are
  # 1: Enables sending data in the opening SYN on the client w/ MSG_FASTOPEN.
  # 2: Enables TCP Fast Open on the server side, i.e., allowing data in
  #    a SYN packet to be accepted and passed to the application before
  #    3-way hand shake finishes.
  # 4: Send data in the opening SYN regardless of cookie availability and
  #    without a cookie option.
  # 0x100: Accept SYN data w/o validating the cookie.
  # 0x200: Accept data-in-SYN w/o any cookie option present.
  # 0x400/0x800: Enable Fast Open on all listeners regardless of the
  #    TCP_FASTOPEN socket option. The two different flags designate two
  #    different ways of setting max_qlen without the TCP_FASTOPEN socket
  #    option.

  #   Note that the client & server side Fast Open flags (1 and 2
  # respectively) must be also enabled before the rest of flags can take
  # effect.

  @staticmethod
  def turn_on_TFO():
    intval = int(0x207)
    return configure('sudo sysctl net.ipv4.tcp_fastopen=' + str(intval))

  @staticmethod
  def turn_off_TFO():
    return configure('sudo sysctl net.ipv4.tcp_fastopen=0')

  @staticmethod
  def set_initcwnd(val=20):
    print "init_cwnd: %s" % (str(val))
    return configure('sudo ip route change default via 172.31.16.1 dev eth0 initcwnd %s' % (str(val)))

  @staticmethod
  def configure_half_rtt(val):

    #Set MTU to 1500 (default MTU for dummynet is 16000)
    configure('sudo ifconfig lo mtu 1500')

    #remove all rules
    configure('sudo ~/ipfw3-2012/ipfw/ipfw flush -f')

    #Add rule for uplink traffic (from client to server)
    configure('sudo ~/ipfw3-2012/ipfw/ipfw add pipe 1 tcp from any to me 8000')

    configure('sudo ~/ipfw3-2012/ipfw/ipfw pipe 1 config bw 256Kbit/s delay %s queue 30k' % (str(val)))

    #Add rule for downlink traffic (from server to client)
    configure('sudo ~/ipfw3-2012/ipfw/ipfw add pipe 2 tcp from me 8000 to any')
    configure('sudo ~/ipfw3-2012/ipfw/ipfw pipe 2 config bw 4Mbit/s delay %s queue 400k' % (str(val)))


