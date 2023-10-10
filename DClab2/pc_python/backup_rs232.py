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
    key = fp_key.read(64)
    enc = fp_enc.read() #times = 9

    enc = enc + enc #times = 18 
    enc = enc + enc #times = 36 4 
    enc = enc + enc #times = 72 8
    enc = enc + enc #times = 144 16 totoros
    print(len(enc))
    enc = enc + enc #times = 288 32 totoros
    print(len(enc))
    enc = enc[0: 32*256]
    print(len(enc))
    


    assert len(enc) % 32 == 0
    

    # calculate send times, actually it's sendtimes-1
    sendTimes = int(len(enc)*2 / len(key)) - 1
    assert (sendTimes >= 0) and (sendTimes <= 255)
    s.write(chr(sendTimes))

    # send key
    s.write(key)

    # send enc
    for i in range(0, len(enc), 32):
        s.write(enc[i:i+32])
        dec = s.read(31)
        fp_dec.write(dec)

    fp_key.close()
    fp_enc.close()
    fp_dec.close()


SendSingleFile('.\golden\key.bin', '.\golden\enc2.bin', '.\golden\dec2.txt')


os.system("type golden\dec2.txt")

