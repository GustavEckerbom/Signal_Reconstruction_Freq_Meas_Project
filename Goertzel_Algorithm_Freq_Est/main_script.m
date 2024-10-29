% Main script to load and analyze signals, estimate frequencies, and plot results

% Step 1: Ask the user to select the .mat file to load
[filename, pathname] = uigetfile('*.mat', 'Select the Reconstructed Signal Package');
if isequal(filename, 0)
    disp('No file selected.');
    return;
end

% Load the selected .mat file
fullpath = fullfile(pathname, filename);
data = load(fullpath);  % Load the .mat file into a structure

% Get the fieldnames (signal names) from the structure
signal_names = fieldnames(data);

% Step 2: Set parameters based on the filename
if contains(filename, '2ksps')
    Fs = 2000;     % Sampling frequency (Hz) for 2ksps
elseif contains(filename, '64ksps')
    Fs = 64000;    % Sampling frequency (Hz) for 64ksps
elseif contains(filename, '150ksps')
    Fs = 150000;   % Sampling frequency (Hz) for 150ksps
elseif contains(filename, '250ksps')
    Fs = 250000;   % Sampling frequency (Hz) for 250ksps
elseif contains(filename, '500ksps')
    Fs = 500000;   % Sampling frequency (Hz) for 500ksps
else
    error('Unrecognized sampling rate in filename.');
end

% Set the total duration based on the filename (20s)
T = 20;

% Define other parameters
window_duration = 0.1;  % 100 ms windows for frequency estimation
window_type = 'hann';   % Choose window type: 'hamming', 'hann', 'blackman', 'none'

% Initialize vectors to store deviation statistics
frequencies = [49, 49.5, 50, 50.5, 51];  % The different frequencies analyzed
max_deviation = zeros(1, length(frequencies));  % Max deviation for each frequency (in mHz)
std_deviation = zeros(1, length(frequencies));  % Standard deviation of errors (in mHz)

% Step 3: Loop through each signal in the structure
for freq_idx = 1:length(frequencies)
    expected_freq = frequencies(freq_idx);
    
    % Modify signal name pattern to match 'Signal_XX_XHz'
    freq_str = sprintf('Signal_%02d_%01dHz', floor(expected_freq), round(10 * mod(expected_freq, 1)));
    
    % Find the signal corresponding to the current frequency
    signal_name = '';
    for i = 1:length(signal_names)
        if contains(signal_names{i}, freq_str)  % Find the signal with the current freq
            signal_name = signal_names{i};
            break;
        end
    end
    
    if isempty(signal_name)
        warning(sprintf('Signal for %.1f Hz not found. Skipping...', expected_freq));
        continue;
    end
    
    % Extract the signal from the structure
    signal = data.(signal_name);
    
    % Step 4: Plot the signal for 51 Hz for illustration purposes
    if expected_freq == 51
        % Reuse or create figure for the 51 Hz plot
        figure_handle_51Hz = findobj('Name', '51 Hz Signal (Time-Domain)');
        if isempty(figure_handle_51Hz)
            figure_handle_51Hz = figure('Name', '51 Hz Signal (Time-Domain)');
        end
        % Pass the figure handle to the plot_signal function
        n_periods = 50;  % Number of periods to plot
        plot_signal(signal, Fs, expected_freq, n_periods, figure_handle_51Hz);  % Function to plot the signal
        title('51 Hz Signal (Time-Domain)');
    end
    
    % Step 5: Estimate the frequency for the current signal
    fprintf('Estimating frequency for the %.1f Hz signal...\n', expected_freq);
    frequency_estimates = estimate_frequency(Fs, window_duration, fullpath, signal_name, window_type);
    
    % Step 6: Calculate deviation and statistics
    errors = frequency_estimates - expected_freq;  % Calculate the error for each window
    max_deviation(freq_idx) = max(abs(errors)) * 1000;  % Convert to mHz
    std_deviation(freq_idx) = std(errors) * 1000;       % Convert to mHz
end

% Step 7: Plot deviation statistics for all frequencies

% Check for the existing figure for deviation statistics and reuse it
figure_handle_deviation = findobj('Name', 'Deviation Statistics');
if isempty(figure_handle_deviation)
    figure_handle_deviation = figure('Name', 'Deviation Statistics');
else
    clf(figure_handle_deviation);  % Clear the figure content if it exists
end
figure(figure_handle_deviation);

% Plot Max Deviation
subplot(2, 1, 1);
bar(frequencies, max_deviation);
xlabel('Frequency (Hz)');
ylabel('Max Deviation (mHz)');
title(sprintf('Maximum Deviation from Expected Frequency (mHz) - Sampling Rate: %d Hz', Fs));  % Add sampling rate to the title
grid on;

% Plot Std Deviation
subplot(2, 1, 2);
bar(frequencies, std_deviation);
xlabel('Frequency (Hz)');
ylabel('Std Deviation of Errors (mHz)');
title(sprintf('Standard Deviation of Frequency Errors (mHz) - Sampling Rate: %d Hz', Fs));  % Add sampling rate to the title
grid on;
