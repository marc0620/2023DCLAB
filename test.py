import math
import matplotlib.pyplot as plt
import numpy as np

# basic parameters
frequeny = 442

duration = 0.1
sampling_rate = 32000
samples = int (duration * sampling_rate)
amplitude = 2**15-1
#amplitude2 = 2**13-1
wavenumber = duration * frequeny


# gerate input waveform
data = []
data2= []
print("generated wavenumber: ", wavenumber)

for i in range(0, samples):
    data.append(int(amplitude * math.sin(2 * math.pi * frequeny * i / sampling_rate)))
    #data2.append(int(amplitude2 * math.sin(2 * math.pi * frequeny * i / sampling_rate)))

# filter1 parameters
sample, sample_D1, sample_D2 = 0, 0, 0
b1, b2, b3, a2, a3 = 67, 0, -67, 130709, -65400
data_pyfilter1 = []
data_pyfilter1_1 = []
temp = 0
for i in range(0, samples):
    sample = data[i]
    sample_D1 = data[i-1] if i-1 >= 0 else 0
    sample_D2 = data[i-2] if i-2 >= 0 else 0
    y_D1 = data_pyfilter1[i-1] if i-1 >= 0 else 0
    y_D2 = data_pyfilter1[i-2] if i-2 >= 0 else 0
    temp = sample * b1 + sample_D1 * b2 + sample_D2 * b3 + y_D1 * a2 + y_D2 * a3
    data_pyfilter1.append(temp>>16)

#    sample2 = data2[i]
#    sample_D12 = data2[i-1] if i-1 >= 0 else 0
#    sample_D22 = data2[i-2] if i-2 >= 0 else 0
#    y_D12 = data_pyfilter1_1[i-1] if i-1 >= 0 else 0
#    y_D22 = data_pyfilter1_1[i-2] if i-2 >= 0 else 0
#    temp2 = sample2 * b1 + sample_D12 * b2 + sample_D22 * b3 + y_D12 * a2 + y_D22 * a3
#    data_pyfilter1_1.append(temp2>>16)
#    if(i<20):
#        #print("1")
#        #print("temp", hex(temp),"sample: ", hex(sample), "sample_D1: ", hex(sample_D1), "sample_D2: ", hex(sample_D2), "y_D1: ", hex(y_D1), "y_D2: ", hex(y_D2))
#        #print("2")
#        #print("temp2",hex(temp2),"sample: ", hex(sample2), "sample_D1: ", hex(sample_D12), "sample_D2: ", hex(sample_D22), "y_D1: ", hex(y_D12), "y_D2: ", hex(y_D22))
#        print("1")
#        print("temp", temp,"sample: ", sample, "sample_D1: ", sample_D1, "sample_D2: ", sample_D2, "y_D1: ", y_D1, "y_D2: ", y_D2)
#        print("2")
#        print("temp2",temp2,"sample: ", sample2, "sample_D1: ", sample_D12, "sample_D2: ", sample_D22, "y_D1: ", y_D12, "y_D2: ", y_D22)



#for i in range(len(data_pyfilter1)):
#    data_pyfilter1[i] *=8
## filter2 parameters

R = int(0.980*2**16)
data_pyfilter2 = []
temp = 0
for i in range(0, samples):
    sample = data_pyfilter1[i]
    sample_D1 = data_pyfilter1[i-1] if i-1 >= 0 else 0
    y_D1 = data_pyfilter2[i-1] if i-1 >= 0 else 0

    temp = (sample<<16) - (sample_D1<<16) + R*y_D1
    data_pyfilter2.append(temp>>16)

for i in range(len(data_pyfilter1)):
    data_pyfilter1[i] /=8
    data_pyfilter2[i] /=8



# Perform DFT
data_fft = np.fft.fft(data)
data_pyfilter1_fft = np.fft.fft(data_pyfilter1)
data_pyfilter2_fft = np.fft.fft(data_pyfilter2)
frequencies = np.fft.fftfreq(len(data), 1/sampling_rate)



with open('data.txt', 'w') as file:
    for item in data:
        file.write(f'{item}\n')

# with open('data_untruncate.txt', 'w') as file:
#     for item in data_raw:
#         file.write(f'{item}\n')


# Load the data
rtl_sim = np.loadtxt('filtered.txt')
for i in range(0, len(rtl_sim)):
    rtl_sim[i] = int(rtl_sim[i])








# ============== Matplotlib settings ==================
fig, axs = plt.subplots(2, 1, figsize=(14, 10))

# Plot original and processed data on the same subplot
axs[0].plot(data, label='Original Data')
axs[0].plot(data_pyfilter1, label='Python process1')
#axs[0].plot(data_pyfilter1_1, label='Python process1_1')
#axs[0].plot(data_pyfilter2, label='Python process2')
axs[0].plot(rtl_sim, label='RTL Simulation')
axs[0].set_title('Original and Processed Data')
axs[0].set_xlabel('Sample')
axs[0].set_ylabel('Amplitude')
axs[0].legend()


# Plot DFT of original data
#axs[1].plot(frequencies[:len(frequencies)//2], np.abs(data_fft)[:len(data_fft)//2], label='DFT of Original Data')
axs[1].plot(frequencies[:len(frequencies)//2], np.abs(data_pyfilter1_fft)[:len(data_pyfilter1_fft)//2], label='DFT of Processed Data1')
axs[1].plot(frequencies[:len(frequencies)//2], np.abs(data_pyfilter2_fft)[:len(data_pyfilter2_fft)//2], label='DFT of Processed Data2')
axs[1].set_title('DFT of Original and Processed Data')
axs[1].set_xlabel('Frequency (Hz)')
axs[1].set_ylabel('Amplitude')
axs[1].legend()

# Display the plots
plt.tight_layout()
plt.show()


print("data_pyfilter1", np.mean(data_pyfilter1))
print("data_pyfilter2", np.mean(data_pyfilter2))
print("rtl_sim", np.mean(rtl_sim))