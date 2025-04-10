# ERC-signal
I have used MatLab for signal processing. I took help from Youtube tutorials and will explain the main parts of the code line by line.
```
Y = fft(f);
```
This computes the Fast Fourier Transform of the signal which will give us a plot of amplitude vs frequency and hep identify the most dominant frequency in the signal. SInce FFT is $\text{FFT}(f)(k) = \overline{\text{FFT}(f)(N - k)}$ where N is the total number of samples, this means that the FFT at index k is the complex conjugate of the same at index (N-k).
```
f_half = ft(1:floor(L/2));
magnitude_half = magnitude(1:floor(L/2));
```
Hence the above lines ensure that only the first half of FFT is kept (because of the symmetry explained). 
```
[~, sorted_idx] = maxk(magnitude_half, 6);
top_freqs = f_half(sorted_idx);
carrier_freq = mean(top_freqs);
```
This finds the indices of the 6 largest peaks in the magnitude spectrum, get the coressponding frequencies for them and then estimate the carrier frequency from the meaan. 
The modulating frequency is then esitmated by seeing how far are the peaks from the carrier frequency. 
```
Wn = [low_cutoff high_cutoff] / (Fs/2);
[x, y] = butter(5, Wn, 'bandpass');
filtered_signal = filtfilt(x, y, f);
```
Wn is the range of frequencies that the filter wants to not remove. I took it as carrier +- 800 since the modulating frequncy was small (500ish) and that was a very small range for a filter which is not ideal. There is a 5th-order Butterworth bandpass filter. Its a standard filter but the n-order deifnes how steep the cutoff is. Higher order means that the filter is very strict about the cutoff frewuncies. filtfilt is the standard command to apply the filter. 
```
envelope = abs(hilbert(filtered_signal));
```
In AM, the carrier wave is high frequeuncy and its used to carry the low frequency signal. So essentially the envelope is the actual audio being moudlated. abs(hilbert) gives the ampltiude of the signal at each point which is what constitutes to the envelope. The aim is to recover the underlying singal present.
```
[b_env, a_env] = butter(6, 2200/(Fs/2),"low");
cleaner_envelope = filtfilt(b_env, a_env, envelope);
[y_env, x_env] = butter(3, 100/(Fs/2),"high");
cleanest_envelope = filtfilt(y_env, x_env, cleaner_envelope);
```
A 6th-order low-pass filter with a cutoff of 2.2 kHz is applied to smoooth the envelope. Similarly a 3rd-order high-pass filter with a 100 Hz cutoff is applied to remove any DC or low-frequency drift. I then normalise and plot the curves and play the audio of the "cleanest_envelop". I tried different values, but these apramters are the ones giving the cleanest audio. 
<p align="center">
  <img src="https://github.com/user-attachments/assets/3050b9f2-a1ba-4ae0-9572-f956952ae48b" width="400">
</p>
^Shows the original singal, envelope, cleaner_envelope and cleanest_envelope


