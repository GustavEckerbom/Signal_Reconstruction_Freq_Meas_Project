Fs = 2000;                       % Sampling frequency
windowtime = 100e-3;             % Window time (100 ms)
window_size = Fs * windowtime;   % Window size calculated from Fs and window_time
prev_phase = [];                 % Initialize the previous phase
frequency_estimates = [];        % List to hold all the frequency estimates

% Load the signals from the .mat file
signals = load('../Load_signals/Reconstructed_Signal_2ksps_20s.mat');

% Extract the 49 Hz signal (use the correct field name from the loaded structure)
signal_49Hz = signals.Signal_49_0Hz_2ksps;

% Determine the total number of windows in the signal
num_samples = length(signal_49Hz);           % Total number of samples in the signal
num_windows = floor(num_samples / window_size);  % Number of full windows that can be extracted

for i = 1:num_windows
    % Get the next window of samples from the signal
    start_idx = (i-1)*window_size + 1;            % Starting index of the current window
    end_idx = i*window_size;                      % Ending index of the current window
    samples = signal_49Hz(start_idx:end_idx);     % Extract the window of samples

    % Estimate the frequency using the real-time function
    [frequency_estimate, prev_phase] = real_time_frequency_estimation(samples, Fs, window_size, prev_phase);

    % Store the frequency estimate
    frequency_estimates(i) = frequency_estimate;
end

% Plot the frequency estimates
figure(1);
plot(frequency_estimates(2:end));
xlabel('Window Number');
ylabel('Frequency Estimate (Hz)');
title('Frequency Estimates Over Time');