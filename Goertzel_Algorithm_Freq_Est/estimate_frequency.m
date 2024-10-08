function frequency_estimates = estimate_frequency(Fs, window_duration, filename, signal_var_name, window_type)
    % estimate_frequency using MATLAB's built-in Goertzel algorithm to estimate the 50 Hz frequency
    % Input:
    %   Fs              - Sampling frequency (Hz)
    %   window_duration - Window duration (seconds)
    %   filename        - The name of the .mat file containing the signals
    %   signal_var_name - The variable name of the signal to analyze (e.g., 'clean_signal' or 'noisy_signal')
    %   window_type     - The type of window to apply ('hamming', 'hann', 'blackman', 'none')
    % Output:
    %   frequency_estimates - Vector of estimated frequencies for each window

    % Load the signal from the .mat file
    data = load(filename);
    
    % Select the signal dynamically based on the variable name passed
    if isfield(data, signal_var_name)
        signal = data.(signal_var_name);  % Dynamically reference the field using the variable name
    else
        error(['Variable ', signal_var_name, ' not found in the .mat file.']);
    end
    
    % Define reference frequency f0 (50 Hz)
    f0 = 50;
    
    % Calculate the window size in samples
    window_size = round(window_duration * Fs); % Window size in samples
    
    % Choose the window function based on input argument
    switch lower(window_type)
        case 'hamming'
            window_function = hamming(window_size);
        case 'hann'
            window_function = hann(window_size);
        case 'blackman'
            window_function = blackman(window_size);
        case 'none'
            window_function = ones(window_size, 1); % No window (i.e., just apply ones)
        otherwise
            error('Unsupported window type. Choose ''hamming'', ''hann'', ''blackman'', or ''none''.');
    end

    % Divide the signal into windows
    n_windows = floor(length(signal) / window_size); % Number of windows
    
    % Initialize variables to store phase estimates and frequency estimates
    phase_estimates = zeros(1, n_windows);
    frequency_estimates = zeros(1, n_windows);
    
    % Calculate the bin corresponding to the reference frequency f0
    k = round((window_size * f0) / Fs);  % Frequency bin index for f0

    % Loop through each window and apply the Goertzel algorithm
    for i = 1:n_windows
        % Extract the current window of the signal
        signal_window = signal((i-1)*window_size + 1:i*window_size);
        
        % Apply the chosen window function to the signal window
        signal_window = signal_window(:) .* window_function(:);  % Ensure both are column vectors
    
        % Apply Goertzel algorithm to find the 50 Hz component
        goertzel_result = goertzel(signal_window, k);  % Use MATLAB's built-in Goertzel function
        
        % Estimate the phase of the 50 Hz component in radians
        phase_estimates(i) = angle(goertzel_result);
    end
    
    % Unwrap the phase to prevent sudden jumps from -pi to pi
    phase_estimates_unwrapped = unwrap(phase_estimates);
    
    % Estimate the frequency from the phase differences
    phase_diff = diff(phase_estimates_unwrapped); % Phase difference between consecutive windows
    frequency_estimates = f0 + (phase_diff / (2 * pi * window_duration)); % Frequency estimation based on window size
end
