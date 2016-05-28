#!/usr/bin/env bash

dir=`pwd`
# Exit on any failure
set -e

# Check for uninitialized variables
set -o nounset

ctrlc() {
    cd $dir
    exit
}
trap ctrlc SIGINT

cd ~
rm -f 20130607-ipfw3.tgz
rm -rf ipfw3-2012
wget http://info.iet.unipi.it/~luigi/doc/20130607-ipfw3.tgz
tar xf 20130607-ipfw3.tgz
cd ipfw3-2012

#Patch taken from https://aur.archlinux.org/packages/dummynet/
patch -p1 -E <<EOF
diff -rupN ipfw3-2012.org/kipfw/ipfw2_mod.c ipfw3-2012/kipfw/ipfw2_mod.c
--- ipfw3-2012.org/kipfw/ipfw2_mod.c	2013-05-02 12:04:52.000000000 +0200
+++ ipfw3-2012/kipfw/ipfw2_mod.c	2015-03-19 20:11:03.972017679 +0100
@@ -218,7 +218,7 @@ ipfw_ctl_h(struct sockopt *s, int cmd, i
 	struct thread t;
 	int ret = EINVAL;

-	memset(s, 0, sizeof(s));
+	memset(s, 0, sizeof(*s));
 	s->sopt_name = cmd;
 	s->sopt_dir = dir;
 	s->sopt_valsize = len;
@@ -466,7 +466,7 @@ static struct nf_sockopt_ops ipfw_sockop
  * so we have an #ifdef to set the proper argument type.
  */
 static unsigned int
-call_ipfw(unsigned int hooknum,
+call_ipfw(const struct nf_hook_ops *ops,
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,23) // in 2.6.22 we have **
 	struct sk_buff  **skb,
 #else
@@ -475,7 +475,7 @@ call_ipfw(unsigned int hooknum,
 	const struct net_device *in, const struct net_device *out,
 	int (*okfn)(struct sk_buff *))
 {
-	(void)hooknum; (void)skb; (void)in; (void)out; (void)okfn; /* UNUSED */
+	(void)ops; (void)skb; (void)in; (void)out; (void)okfn; /* UNUSED */
 	return NF_QUEUE;
 }

@@ -615,7 +615,7 @@ netisr_dispatch(int num, struct mbuf *m)
 #endif

 	/* XXX to obey one-pass, possibly call the queue handler here */
-	REINJECT(info, ((num == -1)?NF_DROP:NF_STOP));	/* accept but no more firewall */
+	REINJECT(info, ((num == -1)?NF_DROP:NF_ACCEPT));	/* accept */
 }

 /*
@@ -724,8 +724,8 @@ linux_lookup(const int proto, const __be
 #define _CURR_GID f_gid
 #else /* 2.6.29 and above */
 /* use the current's file access real uid/gid */
-#define _CURR_UID f_cred->fsuid
-#define _CURR_GID f_cred->fsgid
+#define _CURR_UID f_cred->fsuid.val
+#define _CURR_GID f_cred->fsgid.val
 #endif

 #define GOOD_STATES (	\
@@ -818,18 +818,22 @@ nf_unregister_hooks(struct nf_hook_ops *

 static struct nf_hook_ops ipfw_ops[] __read_mostly = {
         {
+		{ NULL, NULL },
                 .hook           = call_ipfw,
+ 		.owner 		= THIS_MODULE,
+		NULL,
                 .pf             = PF_INET,
                 .hooknum        = IPFW_HOOK_IN,
                 .priority       = NF_IP_PRI_FILTER,
-                SET_MOD_OWNER
         },
         {
+		{ NULL, NULL },
                 .hook           = call_ipfw,
+ 		.owner 		= THIS_MODULE,
+		NULL,
                 .pf             = PF_INET,
                 .hooknum        = NF_IP_POST_ROUTING,
                 .priority       = NF_IP_PRI_FILTER,
-		SET_MOD_OWNER
         },
 };
 #endif /* __linux__ */
diff -rupN ipfw3-2012.org/kipfw/missing.h ipfw3-2012/kipfw/missing.h
--- ipfw3-2012.org/kipfw/missing.h	2013-05-02 12:04:52.000000000 +0200
+++ ipfw3-2012/kipfw/missing.h	2015-03-19 20:10:45.591705704 +0100
@@ -334,6 +334,14 @@ struct ifaltq {
 #define	if_xname	name
 #define	if_snd		XXX
 /* search local the ip addresses, used for the "me" keyword */
+
+struct ptr_heap {
+	void ** ptrs;
+	int max;
+	int size;
+	int (*gt)(void *, void *);
+};
+
 #include <linux/inetdevice.h>

 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,25)
diff -rupN ipfw3-2012.org/sys/netinet/ipfw/ip_dummynet.c ipfw3-2012/sys/netinet/ipfw/ip_dummynet.c
--- ipfw3-2012.org/sys/netinet/ipfw/ip_dummynet.c	2012-08-20 17:43:52.000000000 +0200
+++ ipfw3-2012/sys/netinet/ipfw/ip_dummynet.c	2015-03-19 20:10:45.591705704 +0100
@@ -635,7 +635,7 @@ fsk_detach(struct dn_fsk *fs, int flags)
 		fs->sched->fp->free_fsk(fs);
 	fs->sched = NULL;
 	if (flags & DN_DELETE_FS) {
-		bzero(fs, sizeof(fs));	/* safety */
+		bzero(fs, sizeof(*fs));	/* safety */
 		free(fs, M_DUMMYNET);
 		dn_cfg.fsk_count--;
 	} else {
EOF

make -j3
sudo insmod ~/ipfw3-2012/kipfw-mod/ipfw_mod.ko
cd $dir