% Function to plot the signal for a given number of periods
function plot_signal(signal, Fs, fsig, n_periods, figure_handle)
    % Calculate the number of samples to plot for n periods
    T_period = 1 / fsig;  % Period of the fundamental frequency
    n_samples = round(n_periods * T_period * Fs);  % Number of samples to plot
    
    % Create a time vector for plotting
    t = (0:n_samples-1) / Fs;
    
    % Use the provided figure handle for plotting
    figure(figure_handle);  % Set the figure to the one passed in
    clf(figure_handle);     % Clear the figure before plotting
    
    % Plot the signal
    plot(t, signal(1:n_samples), 'LineWidth', 1.5);
    title(sprintf('Signal Plot (First %d Periods of %.1f Hz)', n_periods, fsig));
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
end
