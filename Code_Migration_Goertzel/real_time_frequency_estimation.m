function [frequency_estimate, prev_phase] = real_time_frequency_estimation(samples, Fs, window_size, prev_phase) %#codegen
    % real_time_frequency_estimation Estimates the frequency of incoming samples.
    % Inputs:
    %   samples     - Incoming signal samples from ADC (real-time data).
    %   Fs          - Sampling frequency.
    %   window_size - Predefined number of samples per window (from configurator).
    %   prev_phase  - Phase from the previous window (to compute phase difference).

    % Define the reference frequency (50 Hz) for Goertzel.
    f0 = 50;
    
    % --- Window Function ---
    % Use Hann window by default
    window_function = hann(window_size);

    % Calculate the bin corresponding to the reference frequency
    k = round((window_size * f0) / Fs);

    % Apply windowing to the incoming samples
    signal_window = samples(:) .* window_function(:);

    % Apply Goertzel algorithm to estimate the frequency component
    goertzel_result = goertzel(signal_window, k);

    % Estimate the phase of the frequency component
    current_phase = angle(goertzel_result);

    % Frequency estimation based on phase difference
    if isempty(prev_phase)
        % If this is the first window, we can't compute the difference yet.
        frequency_estimate = f0; % Assign default frequency estimate for first window
    else
        % Calculate phase difference between the current and previous windows
        phase_diff = current_phase - prev_phase;

        % Phase wrapping
        if phase_diff > pi
            phase_diff = phase_diff - 2 * pi;
        elseif phase_diff < -pi
            phase_diff = phase_diff + 2 * pi;
        end

        % Calculate the frequency estimate
        frequency_estimate = f0 + phase_diff / (2 * pi * window_size / Fs);
    end

    % Update the previous phase for the next window
    prev_phase = current_phase;
end
