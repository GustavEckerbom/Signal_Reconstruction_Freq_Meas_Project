% Step 1: Load the CSV file using readmatrix
data = readmatrix('Long_Measure__2ksps_1048576samples.csv');

% Step 2: Extract the voltage data from the first column
raw_adc_values = data(:, 1);  % Assuming the ADC data is in the first column

% Normalize the raw ADC values to a voltage range of 1.2V
adc_resolution = 24;  % 24-bit ADC
full_scale_voltage = 1.2;  % Full-scale input range of 1.2V
max_adc_value = 2^(adc_resolution - 1) - 1;  % Maximum ADC value (2^23 - 1)
volt = (raw_adc_values / max_adc_value) * full_scale_voltage;  % Normalize to 1.2V

% Step 3: Define the sampling rate and calculate the time increment
sampling_rate = 2000;  % Sampling rate in Hz (2 kHz)
time_increment = 1 / sampling_rate;  % Time increment from sampling rate

% Calculate the total number of samples in the entire dataset
n_samples = length(volt);  % Total number of samples in the full signal
time = (0:n_samples-1) * time_increment;  % Time vector for the full signal

% Signal duration for saving (20 seconds)
save_duration = 20;

% Frequencies and sampling rates to be used
frequencies = [49, 49.5, 50, 50.5, 51];
sampling_rates = [2000, 64000, 150000, 250000, 500000];  % 2ksps, 64ksps, 150ksps
sampling_names = ["2ksps", "64ksps", "150ksps", "250ksps", "500ksps"];

% Find a starting point close to a zero crossing in the original signal
threshold = 0.0001;  % Define a threshold for finding a value close to zero
zero_crossing_idx = find(abs(volt) < threshold, 1);  % Find the first index where the voltage is close to zero

if isempty(zero_crossing_idx)
    warning('No sample near zero found. Using default start time.');
    start_sample = 1;  % Default to the first sample if no zero-crossing is found
else
    start_sample = zero_crossing_idx;
end

% Initialize a structure to store the signals for each sampling rate
for rate_idx = 1:length(sampling_rates)
    high_sampling_rate = sampling_rates(rate_idx);
    time_increment_high = 1 / high_sampling_rate;
    extended_samples_high = save_duration * high_sampling_rate;
    time_extended_high = (0:extended_samples_high-1) * time_increment_high;

    % Structure to hold all signals for this sampling rate
    signal_struct = struct();

    for freq_idx = 1:length(frequencies)
        fundamental_freq = frequencies(freq_idx);

        % Capture a 0.1-second slice from the original signal
        slice_duration = 2;  % Duration of the slice in seconds
        samples_per_slice = slice_duration * sampling_rate;  % Number of samples for 4 seconds
        end_sample = start_sample + samples_per_slice - 1;
        short_signal = volt(start_sample:end_sample);

        % Perform FFT on the raw signal (without windowing)
        windowed_signal = short_signal;  % Use the raw signal directly
        Fs = sampling_rate;
        Y = fft(windowed_signal, samples_per_slice);

        % Calculate the frequency vector for positive frequencies
        f = Fs * (0:(samples_per_slice/2)) / samples_per_slice;
        f = f(:);  % Ensure f is a column vector to match P1

        % Compute the magnitude spectrum
        P = abs(Y / samples_per_slice);
        P1 = P(1:samples_per_slice/2+1);  % One-sided spectrum

        % Convert the FFT magnitude to dBc
        max_fft_value = max(P1);
        P1_dBc = 20 * log10(P1 / max_fft_value);

        % Identify the noise floor and threshold
        noise_floor_dBc = mean(P1_dBc);  % Use mean value of the spectrum as noise floor
        threshold_dBc = noise_floor_dBc + 10;

        % Define the harmonic frequencies (50, 100, 150, ..., 1000 Hz)
        harmonics = 50:50:1000;  % Fundamental and harmonic frequencies
        
        % Initialize the significant_bins array as all false
        significant_bins = false(size(f));  
        
        % Loop through each harmonic and find the closest bin to the harmonic frequency
        for harmonic = harmonics
            % Find the index of the closest frequency bin to the current harmonic
            [~, bin_idx] = min(abs(f - harmonic));
            
            % Mark only the closest bin as significant
            significant_bins(bin_idx) = true;
        end

        % Get phase information from the FFT result
        phase = angle(Y);  % Phase of each frequency bin

        % Define delta_f based on the fundamental frequency
        delta_f = fundamental_freq - 50;  % Difference from 50 Hz

        % Shift the harmonics based on the user input and delta_f
        [P1_shifted, phase_shifted] = shift_harmonics(f, P1, phase, significant_bins, delta_f);

        % Reconstruct the extended signal at the higher sampling rate
        reconstructed_signal_extended_high = zeros(1, extended_samples_high);  % Initialize
        for k = 1:length(f)
            if P1_shifted(k) > 0  % Only consider non-zero bins
                amplitude = P1_shifted(k);
                if k > 1 && k < length(f)  % Double amplitude for non-DC/non-Nyquist components
                    amplitude = 2 * amplitude;
                end
                phase_k = phase_shifted(k);
                reconstructed_signal_extended_high = reconstructed_signal_extended_high + ...
                    amplitude * cos(2 * pi * f(k) * time_extended_high + phase_k);
            end
        end

        % Add white noise to the high-rate reconstructed signal
        n_bins = samples_per_slice / 2;  % Half the bins are used for one-sided spectrum
        noise_floor_linear = 10^(noise_floor_dBc / 20);
        total_noise_power = noise_floor_linear * sqrt(n_bins);  % Total noise power
        white_noise_high = total_noise_power * randn(1, extended_samples_high);  % White noise
        reconstructed_signal_with_noise_extended_high = reconstructed_signal_extended_high + white_noise_high;

        % Format the signal name for the structure
        if mod(fundamental_freq, 1) == 0
            % If the frequency is an integer, format without a decimal
            signal_name = sprintf('Signal_%02d_0Hz_%s', fundamental_freq, sampling_names(rate_idx));
        else
            % If the frequency has a decimal, format with an underscore instead of a period
            signal_name = sprintf('Signal_%02d_%01dHz_%s', floor(fundamental_freq), round(10*(fundamental_freq-floor(fundamental_freq))), sampling_names(rate_idx));
        end

        signal_struct.(signal_name) = reconstructed_signal_with_noise_extended_high;
    end

    % Define the subfolder name (relative to the current directory)
    subfolder = 'Load_signals';
    
    % Check if the subfolder exists; if not, create it
    if ~exist(subfolder, 'dir')
        mkdir(subfolder);
    end
    
    % Save the signals to a .mat file in the subfolder
    filename = sprintf('Reconstructed_Signal_%s_%ds.mat', sampling_names(rate_idx), save_duration);
    fullpath = fullfile(subfolder, filename);
    save(fullpath, '-struct', 'signal_struct');
end

% //////////// Helper functions //////////////

function [P1_shifted, phase_shifted] = shift_harmonics(f, P1, phase, significant_bins, delta_f)
    % Initialize the shifted vectors
    P1_shifted = zeros(size(P1));  
    phase_shifted = zeros(size(phase));

    % Loop through the fundamental and harmonic frequencies
    for k = 1:length(f)
        if significant_bins(k)  % Only shift significant harmonic bins
            harmonic_shift = delta_f;  % Shift based on the fundamental frequency offset

            new_freq = f(k) + harmonic_shift;  % Shift the frequency

            % Find the closest new bin (after shifting)
            [~, new_idx] = min(abs(f - new_freq));

            % Move amplitude and phase to the new bin
            P1_shifted(new_idx) = P1(k);
            phase_shifted(new_idx) = phase(k);
        end
    end
end
