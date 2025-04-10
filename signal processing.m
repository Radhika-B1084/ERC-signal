    [f, Fs] = audioread("modulated_noisy_audio.wav");
    L = length(f);
    t = (0:L-1)/Fs;
    
    Y = fft(f);
    ft = (0:L-1)*(Fs/L);
    magnitude = abs(Y)/L;
    f_half = ft(1:floor(L/2));
    magnitude_half = magnitude(1:floor(L/2));
    [~, sorted_idx] = maxk(magnitude_half, 6);
    top_freqs = f_half(sorted_idx);
    carrier_freq = mean(top_freqs);
    modulating_freq = mean(abs(top_freqs - carrier_freq));
    
    low_cutoff = (carrier_freq - 800);
    high_cutoff = (carrier_freq + 800);
    Wn = [low_cutoff high_cutoff] / (Fs/2);
    [x, y] = butter(5, Wn, 'bandpass');  
    filtered_signal = filtfilt(x, y, f);
    envelope = abs(hilbert(filtered_signal));
  
    %LOW PASS FILTER
    [b_env, a_env] = butter(6, 2200/(Fs/2),"low");  % 3 kHz low-pass
    cleaner_envelope = filtfilt(b_env, a_env, envelope);
    
    %HIGH PASS FILTER
    [y_env, x_env] = butter(3, 100/(Fs/2),"high");
    cleanest_envelope = filtfilt(y_env, x_env, cleaner_envelope);
    cleanest_envelope = cleanest_envelope / max(abs(cleanest_envelope));
    cleanest_envelope = cleanest_envelope - mean(cleanest_envelope);

    subplot(4,1,1);
    plot(t,f);
    subplot(4,1,2);
    plot(t, envelope);
    subplot(4,1,3);
    plot(t, cleaner_envelope);
    subplot(4,1,4);
    plot(t, cleanest_envelope);
    soundsc(cleanest_envelope, Fs);