import math
import matplotlib.pyplot as plt
import numpy as np

# basic parameters
frequeny = 442
duration = 0.1
sampling_rate = 32000
samples = int (duration * sampling_rate)
amplitude = 2**10
wavenumber = duration * frequeny


# gerate input waveform
data = []
print("generated wavenumber: ", wavenumber)
for i in range(0, samples):
    data.append(int(amplitude * math.sin(2 * math.pi * frequeny * i / sampling_rate)))


# filter parameters
sample, sample_D1, sample_D2 = 0, 0, 0
b1, b2, b3, a2, a3 = 67, 0, -67, 130709, -65400
data_processed = []
temp = 0
for i in range(0, samples):
    sample = data[i]
    sample_D1 = data[i-1] if i-1 >= 0 else 0
    sample_D2 = data[i-2] if i-2 >= 0 else 0
    y_D1 = data_processed[i-1] if i-1 >= 0 else 0
    y_D2 = data_processed[i-2] if i-2 >= 0 else 0

    temp = sample * b1 + sample_D1 * b2 + sample_D2 * b3 + y_D1 * a2 + y_D2 * a3
    data_processed.append(temp>>16)





# Perform DFT
# data_fft = np.fft.fft(data)
# data_processed_fft = np.fft.fft(data_processed)
# frequencies = np.fft.fftfreq(len(data), 1/sampling_rate)



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
axs[0].plot(data_processed, label='Processed Data')
axs[0].plot(rtl_sim, label='RTL Simulation')
axs[0].set_title('Original and Processed Data')
axs[0].set_xlabel('Sample')
axs[0].set_ylabel('Amplitude')
axs[0].legend()


# Plot DFT of original data
# axs[1].plot(frequencies[:len(frequencies)//2], np.abs(data_fft)[:len(data_fft)//2], label='DFT of Original Data')
# axs[1].plot(frequencies[:len(frequencies)//2], np.abs(data_processed_fft)[:len(data_processed_fft)//2], label='DFT of Processed Data')
# axs[1].set_title('DFT of Original and Processed Data')
# axs[1].set_xlabel('Frequency (Hz)')
# axs[1].set_ylabel('Amplitude')
# axs[1].legend()

# Display the plots
plt.tight_layout()
plt.show()
