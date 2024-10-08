% Script to load and plot FFTs of the original and reconstructed signals (up to 1kHz if applicable)

% Step 1: Ask the user to select the .mat file to load
[filename, pathname] = uigetfile('*.mat', 'Select the Reconstructed Signal Package');
if isequal(filename,0)
    disp('No file selected.');
    return;
end

% Load the selected .mat file
fullpath = fullfile(pathname, filename);
signal_data = load(fullpath);  % Load the .mat file into a structure

% Get the fieldnames (signal names) from the structure
signal_names = fieldnames(signal_data);

% Step 2: Define the sampling rate for each signal (extracted from the file name)
sampling_rate = str2double(regexp(filename, '\d+', 'match', 'once')) * 1000;  % Extract sampling rate (2ksps, 64ksps, 150ksps)

% Step 3: Find the signal that corresponds to 50 Hz in the signal names
signal_50Hz_name = '';
for i = 1:length(signal_names)
    if contains(signal_names{i}, '50_0Hz')
        signal_50Hz_name = signal_names{i};
        break;
    end
end

% Ensure that we found the 50 Hz signal
if isempty(signal_50Hz_name)
    disp('50 Hz signal not found in the loaded file.');
    return;
end

% Extract the reconstructed 50 Hz signal
reconstructed_signal_50Hz = signal_data.(signal_50Hz_name);

% Load the original 2kHz signal CSV file
data = readmatrix('../Long_Measure__2ksps_1048576samples.csv');
raw_adc_values = data(:, 1);  % Assuming the ADC data is in the first column

% Normalize the raw ADC values to a voltage range of 1.2V
adc_resolution = 24;  % 24-bit ADC
full_scale_voltage = 1.2;  % Full-scale input range of 1.2V
max_adc_value = 2^(adc_resolution - 1) - 1;  % Maximum ADC value (2^23 - 1)
original_signal = (raw_adc_values / max_adc_value) * full_scale_voltage;  % Normalize to 1.2V

% Original sampling rate (assumed 2kHz from the file name)
original_sampling_rate = 2000;

% Set the time duration for both signals to 2 seconds for consistent resolution
time_duration = 2;  % 2-second slice
samples_to_plot_original = time_duration * original_sampling_rate;  % Number of samples for 2 seconds of original signal
samples_to_plot_reconstructed = time_duration * sampling_rate;  % Number of samples for 2 seconds of reconstructed signal

% Step 4: Compute FFTs using 2 seconds for both original and reconstructed signals
% Compute the FFT of the original signal (2 seconds)
original_length = samples_to_plot_original;  % Use 2 seconds of the original signal
Y_original = fft(original_signal(1:original_length));
P2_original = abs(Y_original/original_length);
P1_original = P2_original(1:floor(original_length/2)+1);
P1_original(2:end-1) = 2*P1_original(2:end-1);  % Adjust for one-sided spectrum

f_original = original_sampling_rate*(0:(original_length/2))/original_length;

% Compute the FFT of the reconstructed signal (use 2 seconds only)
reconstructed_length = samples_to_plot_reconstructed;  % Use 2 seconds of the reconstructed signal
Y_reconstructed = fft(reconstructed_signal_50Hz(1:reconstructed_length));
P2_reconstructed = abs(Y_reconstructed/reconstructed_length);
P1_reconstructed = P2_reconstructed(1:floor(reconstructed_length/2)+1);
P1_reconstructed(2:end-1) = 2*P1_reconstructed(2:end-1);  % Adjust for one-sided spectrum

f_reconstructed = sampling_rate*(0:(reconstructed_length/2))/reconstructed_length;

% Step 5: Plot FFTs
% Create a new figure for FFT comparison
figure('Name', 'FFT Comparison (First 1kHz)');

% Subplot 1: FFT of the original signal (1kHz limit)
subplot(2, 1, 1);
plot(f_original, 20*log10(P1_original));
xlim([0 1000]);  % Limit to 1 kHz
title('FFT of Original Signal (up to 1kHz, 2 Second Slice)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dBc)');
grid on;

% Subplot 2: FFT of the reconstructed signal (1kHz limit)
subplot(2, 1, 2);
plot(f_reconstructed, 20*log10(P1_reconstructed));
xlim([0 1000]);  % Limit to 1 kHz
title(sprintf('FFT of Reconstructed Signal (up to 1kHz, %.0f kHz Sampling Rate, 2 Second Slice)', sampling_rate / 1000));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dBc)');
grid on;

% Overlay Plot (Original in Blue, Reconstructed in Black)
figure('Name', 'Overlay of FFTs (Original vs Reconstructed, First 1kHz)');
plot(f_original, 20*log10(P1_original), 'b', 'LineWidth', 1.5);  % Original in blue
hold on;
plot(f_reconstructed, 20*log10(P1_reconstructed), 'k', 'LineWidth', 1.5);  % Reconstructed in black
xlim([0 1000]);  % Limit to 1 kHz
title('Overlay of FFTs (Original vs Reconstructed, First 1kHz)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dBc)');
grid on;
legend('Original Signal', 'Reconstructed Signal');
hold off;
