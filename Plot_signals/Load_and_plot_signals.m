% Script to load and plot signals and their FFTs from a .mat file package

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

% Step 3: Set the time duration to plot (1 second)
time_duration = 1;  % Plot the first 1 second
samples_to_plot = time_duration * sampling_rate;  % Number of samples for 1 second

% Find the signal that corresponds to 49 Hz in the signal names
signal_49Hz_name = '';
for i = 1:length(signal_names)
    if contains(signal_names{i}, '49_0Hz')
        signal_49Hz_name = signal_names{i};
        break;
    end
end

% Ensure that we found the 49 Hz signal
if isempty(signal_49Hz_name)
    disp('49 Hz signal not found in the loaded file.');
    return;
end

% Extract the reconstructed 49 Hz signal
reconstructed_signal_49Hz = signal_data.(signal_49Hz_name);

% Plotting the original signal and reconstructed signal

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
samples_to_plot_original = time_duration * original_sampling_rate;  % Samples for 1 second

% Step 4: Create a new figure for time-domain comparison
figure('Name', 'Time-Domain Comparison');

% Subplot 1: Original 2kHz signal for the first 1 second
time_original = (0:samples_to_plot_original-1) / original_sampling_rate;
subplot(2, 1, 1);
plot(time_original, original_signal(1:samples_to_plot_original));
title('Original Signal (1 Second, 2 kHz Sampling Rate)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Subplot 2: Reconstructed 49Hz signal for the first 1 second
time_reconstructed = (0:samples_to_plot-1) / sampling_rate;
subplot(2, 1, 2);
plot(time_reconstructed, reconstructed_signal_49Hz(1:samples_to_plot));
title(sprintf('Reconstructed Signal (1 Second, 49 Hz, %.0f kHz Sampling Rate)', sampling_rate / 1000));
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Adjust the layout of subplots
sgtitle('Comparison of Original and Reconstructed Signals (1 Second)');
