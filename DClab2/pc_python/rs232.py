#!/usr/bin/env python
from serial import Serial, EIGHTBITS, PARITY_NONE, STOPBITS_ONE
from sys import argv
import os

# assert len(argv) == 2
s = Serial(
    port='COM5',#argv[1]
    baudrate=115200,
    bytesize=EIGHTBITS,
    parity=PARITY_NONE,
    stopbits=STOPBITS_ONE,
    xonxoff=False,
    rtscts=False
)


def SendSingleFile(key_file, enc_file, dec_file): 
    # open files
    fp_key = open(key_file, 'rb')
    fp_enc = open(enc_file, 'rb')
    fp_dec = open(dec_file, 'wb')
    assert fp_key and fp_enc and fp_dec

    # read files
    key = fp_key.read()
    enc = fp_enc.read()

    assert len(enc) % 32 == 0

    # calculate send times, actually it's sendtimes-1
    sendTimes = int(len(enc)*2 / len(key)) - 1
    assert (sendTimes >= 0)

    while sendTimes > 255:
        sendThisTime = enc[0: 256*32]
        enc = enc[256*32:]

        # send times, key, enc
        s.write(chr(255))
        s.write(key)
        for i in range(0, 256*32, 32):
            s.write(sendThisTime[i:i+32])
            dec = s.read(31)
            fp_dec.write(dec)
        
        sendTimes = int(len(enc)*2 / len(key)) - 1
        assert (sendTimes >= 0)

    
    # send times, key, enc
    s.write(chr(sendTimes))
    s.write(key)
    for i in range(0, len(enc), 32):
        s.write(enc[i:i+32])
        dec = s.read(31)
        fp_dec.write(dec)

    fp_key.close()
    fp_enc.close()
    fp_dec.close()


SendSingleFile('key.bin', 'enc_long.bin', 'dec.bin')

os.system("type dec.bin")

