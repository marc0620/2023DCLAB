% Generate a waveform with all frequencies from 1 to 1000 Hz
Fs = 48000;  % Sampling frequency
t = 0:1/Fs:1/300;  % Time vector (2 seconds)

% Generate the waveform using element-wise addition
%waveform = sum(sin(2*pi*(1:1000)'*t), 1);  % Note the transpose (') here

% waveform = sin(2*pi*100*t) + sin(2*pi*200*t) + sin(2*pi*300*t) + sin(2*pi*400*t) + sin(2*pi*500*t) + sin(2*pi*600*t) + sin(2*pi*700*t) + sin(2*pi*900*t);
% waveform = sin(2*pi*300*t) +  sin(2*pi*600*t) + sin(2*pi*900*t);
%waveform = sin(2*pi*300*t) +  sin(2*pi*1600*t) + sin(2*pi*2900*t);

%waveform with sampling freq = 50000
% waveform = [0,0,3688,7265,10628,13677,16325,18499,20143,21219,21708,21613,20958,19786,18156,16144,13842,11347,8767,6209,3782,1586,-285,-1750,-2741,-3211,-3129,-2486,-1290,424,2608,5195,8101,11233,14488,17757,20932,23905,26575,28852,30658,31934,32634,32735,32232,31146,29510,27382,24833,21950,18832,15582,12310,9125,6132,3429,1102,-775,-2147,-2977,-3246,-2958,-2136,-822,921,3019,5381,7907,10492,13027,15405,17523,19289,20622,21455,21741,21447,20566,19108,17105,14608,11683,8415,4898,1235,-2465,-6092,-9537,-12702,-15492,-17831,-19657,-20925,-21610,-21708,-21237,-20231,-18746,-16852,-14635,-12194,-9630,-7053,-4570,-2286,-296,1312,2467,3115,3219,2762,1749,202,-1831,-4292,-7102,-10170,-13397,-16674,-19892,-22943,-25724,-28141,-30112,-31570,-32466,-32768,-32466,-31570,-30112,-28141,-25724,-22943,-19892,-16674,-13397,-10170,-7102,-4292,-1831,202,1749,2762,3219,3115,2467,1312,-296,-2286,-4570,-7053,-9630,-12194,-14635,-16852,-18746,-20231,-21237,-21708,-21610,-20925,-19657,-17831,-15492,-12702,-9537,-6092];

%waveform with sampling freq = 48000
waveform = [0,0,3839,7555,11028,14148,16819,18962,20516,21447,21740,21407,20482,19023,17108,14831,12298,9630,6947,4371,2019,0,-1592,-2679,-3202,-3129,-2446,-1167,672,3013,5777,8867,12175,15582,18965,22201,25171,27767,29893,31470,32440,32768,32440,31470,29893,27767,25171,22201,18965,15582,12175,8867,5777,3013,672,-1167,-2446,-3129,-3202,-2679,-1592,0,2019,4371,6947,9630,12298,14831,17108,19023,20482,21407,21740,21447,20516,18962,16819,14148,11028,7555,3839,0,-3839,-7555,-11028,-14148,-16819,-18962,-20516,-21447,-21740,-21407,-20482,-19023,-17108,-14831,-12298,-9630,-6947,-4371,-2019,0,1592,2679,3202,3129,2446,1167,-672,-3013,-5777,-8867,-12175,-15582,-18965,-22201,-25171,-27767,-29893,-31470,-32440,-32768,-32440,-31470,-29893,-27767,-25171,-22201,-18965,-15582,-12175,-8867,-5777,-3013,-672,1167,2446,3129,3202,2679,1592,0,-2019,-4371,-6947,-9630,-12298,-14831,-17108,-19023,-20482,-21407,-21740,-21447,-20516,-18962,-16819,-14148,-11028,-7555,-3839];

lenght = length(t)

% Compute FFT of the original signal
n = length(waveform);
fft_original = fft(waveform);
frequencies_original = (0:n-1)*(Fs/n);

% Design a Butterworth filter
% cutoff_frequency = 200;  % Adjust as needed
% order = 2;
% [b, a] = butter(order, cutoff_frequency/(Fs/2));

%  -- bandpass
%% M(f) = 1125*ln(1+f/700)
%% F(m) = 700*(exp(m/1125)-1)
%% want equispace 300 Hz to 3800 Hz
%% M(300) = 401.25 : M(3500)=2016
%M = linspace(401.25, 2016, 32);
%F = 700*(exp(M/1125)-1)/(Fs/2);
%%F = logspace(log10(300),log10(3800),32)/(Fs/2) ; % normalized freq
%% make the bandpass edges cross at about 50%
%BW = 0.035*(0.15 ./(F) + 1); % of freq
%% generate the filters
%for i=1:length(F)
%    %i
%    [b{i}, a{i}] = butter(1,[F(i)-F(i)*(BW(i)/2), F(i)+F(i)*(BW(i)/2)] );
%    %disp(b{i});
%    %disp(a{i});
%end

% import butterworth coefficient
    % test cornell github iir filter one for which freq = 299.991723 Hz
    %a = [1,-130880,65445];
    %b = [45,0,-45];
    
    % for freq = 1500Hz
      a = [-1,1.9549,-0.9931];
      b = [0.0034,0,-0.0034];

%       [h2,w2]=freqz(b,a,100);
%       h2_db=20*log(abs(h2));
%       h2_abs = abs(h2);
%       figure;
%       plot(w2,h2_abs);

    % for freq = 6000Hz
    % a=[-1,1.3952,-0.9729];
    % b=[0.0136,0,-0.0136];

    

% Apply the Butterworth filter
filtered_signal = filter(b, a, waveform);

% Compute FFT of the filtered signal
fft_filtered = fft(filtered_signal);

% fft_filtered_back = fft_filtered(5001:10001);

frequencies_filtered = (0:n-1)*(Fs/n);
%frequencies_filtered = linspace(1,10001,1);

% Plot the original signal and its FFT
figure;
subplot(3, 2, 1);
plot(t, waveform);
title('Original Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 2, 2);
plot(frequencies_original, abs(fft_original));
title('FFT of Original Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

% Plot the filtered signal and its FFT
subplot(3, 2, 3);
plot(t, filtered_signal);
title('Filtered Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 2, 4);
plot(frequencies_filtered, abs(fft_filtered));
title('FFT of Filtered Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

sgtitle('Waveform, FFT, and Butterworth Filtering');

%subplot(3, 2, 5);
%plot(frequencies_filtered(5001:10001), abs(fft_filtered_back));
% Play the original audio
sound(waveform, Fs);
pause(5); % Pause to allow sound to finish

% Play the filtered audio
sound(250*filtered_signal, Fs);
pause(2); % Pause to allow sound to finish

% from Verilog
hardware_filtered_signal = [   0,
   0,
  13,
  51,
 111,
 188,
  277,
  371,
  462,
  543,
  606,
  645,
  654,
  629,
  568,
  471,
  340,
  179,
   -7,
 -210,
 -421,
 -630,
 -826,
 -999,
-1139,
-1236,
-1283,
-1274,
-1206,
-1079,
 -895,
 -658,
 -376,
  -59,
  281,
  630,
  973,
 1295,
 1581,
 1817,
 1990,
 1866,
 1671,
 1632,
 1522,
 1341,
 1093,
  785,
  427,
   32,
 -385,
 -808,
-1220,
-1603,
-1940,
-2215,
-2414,
-2526,
-2544,
-2463,
-2283,
-2008,
-1646,
-1209,
 -712,
 -174,
  385,
  943,
 1477,
 1965,
 2385,
 2718,
 2948,
 3063,
 3055,
 2921,
 2663,
 2288,
 1808,
 1239,
  601,
  -82,
 -784,
-1477,
-2134,
-2728,
-3234,
-3630,
-3897,
-4022,
-3997,
-3820,
-3494,
-3029,
-2440,
-1748,
  -978,
  -159,
   678,
  1501,
  2277,
  2975,
  3566,
  4025,
  4332,
  4472,
  4437,
  4225,
  3842,
  3300,
  2617,
  1818,
   933,
    -5,
  -960,
 -1895,
 -2773,
 -3558,
 -4218,
 -4725,
 -5057,
 -5198,
 -5140,
 -4882,
 -4431,
 -3801,
 -3014,
 -2098,
 -1087,
   -19,
  1065,
  2123,
  3114,
  3998,
  4740,
  5309,
  5681,
  5839,
  5774,
  5486,
  4984,
  4285,
  3414,
  2403,
  1290,
   117,
 -1071,
 -2228,
 -3309,
 -4271,
 -5075,
 -5688,
 -6084,
 -6245,
 -6162,
 -5836,
 -5277,
 -4504,
 -3545,
 -2435,
 -1215];
subplot(3, 2, 5);
plot(t, hardware_filtered_signal);
title('Hardware Filtered Signal');
xlabel('Time (s)');
ylabel('Amplitude');

fft_hardware_filtered = fft(hardware_filtered_signal);

subplot(3, 2, 6);
plot(frequencies_original, abs(fft_hardware_filtered));
title('FFT of Hardware Filtered Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

sound(hardware_filtered_signal, Fs);