
# Signal Generation and Analysis Project

This project is designed to analyze a 50 Hz grid signal, decompose its frequency and noise components, and reconstruct a new signal with a specified fundamental frequency. The power of the overtones (harmonics) in the reconstructed signal is preserved, and various sampling rates can be used to create the signal for further analysis.

## Project Structure

The project includes the following key components:

### 1. Signal Generation (`Signal_Generation.m`)

This script generates signals based on an input measurement of a 50 Hz grid signal. It performs the following steps:
- Loads the original measured signal (`Long_Measure__2ksps_1048576samples.csv`).
- Decomposes the signal into its frequency components using FFT.
- Reconstructs a new signal with a fundamental frequency (49 Hz to 51 Hz) and maintains the harmonic power distribution.
- Supports different sampling rates: 2 ksps, 64 ksps, 150 ksps, 250ksps and 500ksps.
- Adds white noise based on the noise floor of the original signal.
- Saves the reconstructed signals into `.mat` files for further analysis.

You can configure the length of the signal by changing the save_duration variable in the signal generation script. 

### 2. Load and Plot Signals (`Load_and_plot_signals.m`)

This script allows you to:
- Load a `.mat` file containing the reconstructed signals.
- Compare the time-domain representation of the reconstructed 50 Hz signal with the original 50 Hz signal (measured at 2 ksps).
- Visualize the signals in subplots, with the original signal in one subplot and the reconstructed signal in another.

### 3. FFT Comparison (`Plot_FFT_Comparison.m`)

This script is used to:
- Load a `.mat` file containing the reconstructed signals.
- Plot and compare the FFT of the original signal (from the measured CSV file) with the FFT of the reconstructed signal.
- Limit the frequency range to the first 1 kHz for better comparison.
- Overlay the FFT plots for direct comparison of frequency components (with original signal in blue and reconstructed signal in black).

## How to Use the Project

1. **Signal Generation**:
   - If the `Load_Signals` folder is empty or you want to regenerate the signal data, simply run `Signal_Generation.m` to generate signals with specified fundamental frequencies (49, 49.5, 50, 50.5, 51 Hz) and save the signals into `.mat` files.
   - The reconstructed signals will be saved into different `.mat` files, such as:
     - `Reconstructed_Signal_2ksps_40s.mat`
     - `Reconstructed_Signal_64ksps_40s.mat`
     - `Reconstructed_Signal_150ksps_40s.mat`
    The save name depends on the sampling frequency and the save duration and all has the above format.
   
2. **Loading and Plotting Signals**:
   - Run `Load_and_plot_signals.m` to load one of the `.mat` files and compare the time-domain representation of the reconstructed 50 Hz signal with the original signal.
   - Example usage:
     - The script will ask you to select a `.mat` file. It will automatically load the original signal from `Long_Measure__2ksps_1048576samples.csv` and plot the signals for comparison.

3. **FFT Comparison**:
   - Run `Plot_FFT_Comparison.m` to load one of the `.mat` files and compare the FFT of the reconstructed 50 Hz signal with the original signal.
   - Example usage:
     - The script will ask you to select a `.mat` file. It will plot the FFTs of both the original and reconstructed signals, and limit the frequency range to the first 1 kHz.

## Example Usage

### Loading and Plotting Signals

To compare the original signal and the reconstructed signal:

```matlab
run('Load_and_plot_signals.m');
```

- The script will prompt you to select a `.mat` file containing the reconstructed signals.
- After selecting the file, it will load the original 50 Hz signal from the CSV and plot both signals for comparison.

### FFT Comparison

To compare the FFTs of the original and reconstructed signals:

```matlab
run('Plot_FFT_Comparison.m');
```
- The script will prompt you to select a `.mat` file containing the reconstructed signals.
- It will then compute and plot the FFTs of both the original and reconstructed signals, with the frequency range limited to 1 kHz for better comparison.

## File Structure

- `Signal_Generation.m`: Script to generate and save the reconstructed signals.
- `Long_Measure__2ksps_1048576samples.csv`: Input CSV file containing the measured 50 Hz grid signal.
- `Load_and_plot_signals.m`: Script to load and plot the time-domain signals for comparison.
- `Plot_FFT_Comparison.m`: Script to compare the FFTs of the original and reconstructed signals.

## Subfolders

- `Plot_signals/`: Contains plots the scripts needed to visualize the signals.
- `Load_signals/`: Contains the `.mat` files with the reconstructed signals that has been saved.
- `Goertzel_Algorithm_Freq_Est/`: Contains the scripts used to run frequeny estiamtion on an entire input signal
- `Code_Migration_Goertzel/`: Contains the scripts used to run frequeny estiamtion on an entire input signal sliced up to a realtime like seting. The method only knows the latest 100ms of data each estiamtion round. 