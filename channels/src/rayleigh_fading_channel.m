

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title     : Simulation of a Rayleigh Fading Wireless Channel
% Author    : balarcode
% Version   : 2.1
% Date      : 9th May 2025
% File Type : Matlab Script
% File Test : Verified on Matlab R2024b
% Comments  : Short-term fast fading of a wireless channel
%             can be modeled as a Rayleigh fading channel.
%             The channel has no line of sight (LOS) between transmitter
%             and receiver and includes multipath propagation of a
%             transmitted EM wave through multiple scatterers in the
%             vicinity of the wireless receiver.
%             Rayleigh fading channel is a statistical channel model.
%
% All Rights Reserved.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

clear
close all

%-------------------------------------------------------------------------
% Simulation Parameter Initialization
%-------------------------------------------------------------------------
% Maximum Doppler frequency due to wireless receiver's motion
fd_max = 200;

% Sampling period (To be taken to be less than the Doppler period)
Ts = 0.1/fd_max;
fs = 1/Ts; % Sampling frequency

% Carrier frequency
fc = 1.8e9;
lambda = 3e8/fc; % velocity (m/s) / frequency (Hz)

% Number of samples considered in the simulation
num_samples = 10^6;

M = 32;
n = 1 : M;
N = 4 * M;

% Initialize r_i and r_q to all zeros
r_i = zeros(1, num_samples); % Returns a vector of order 1 x num_samples with elements being zeros
r_q = r_i;

%-------------------------------------------------------------------------
% Simulation of a Rayleigh Fading Wireless Channel
%-------------------------------------------------------------------------
% Doppler frequency
fn = fd_max * cos(2 * pi * (n-0.5)/N); 
% NOTE: Since the Doppler frequency is very small compared to the carrier frequency,
%       the electric field components can be modeled as a narrow band random process.

% angle_n is the angle of the nth scattered wave arriving at the receiver w.r.t the direction of motion of the receiver
% NOTE: The scattered waves arrive at a uniform distribution angle.
angle_n = pi * n/(M); 

% 'alpha_n' is a real random variable representing the amplitude of the scattered waves
alpha_n = sign(randn(1, M));

% The phase of the scattered waves are statistically independent and
% uniformly distributed in (0, 2*pi)
theta = 2 * pi * rand(1, M);

m = (1 : num_samples);

% Phase of the nth scattered wave arriving at the receiver with 
% Doppler shift included = (2*pi*fn*t)+theta; where 't' is sampled at 'm*Ts'
for idx = 1 : M
    r_i(m) = r_i(m) + alpha_n(idx) * cos(angle_n(idx)) * cos(2*pi*fn(idx)*m*Ts+theta(idx));
    r_q(m) = r_q(m) + alpha_n(idx) * sin(angle_n(idx)) * cos(2*pi*fn(idx)*m*Ts+theta(idx));
end
% NOTE-1: r_i and r_q represent the Gaussian random variables for the in-phase and 
%         quadrature-phase of the resultant electric field at the wireless receiver.
%         These two Gaussian random variables are independent and identically distributed.
% NOTE-2: Jakes Method uses Sum of Sinusoids to obtain the Gaussian random
%         variables with Doppler shift and angle of arrival included.

% Complex baseband fading signal from a Rayleigh fading channel
fading_signal = (r_i + 1i*r_q) * (sqrt(2/M));
% NOTE: Also called as Rayleigh fading channel coefficients.

% NOTE: The distribution of magnitude of the fading signal follows a 
% Rayleigh probability distribution.
magnitude_fading_signal = abs(fading_signal);

%------------------------------------------------------------------------
% TRANSMIT DATA
%------------------------------------------------------------------------
transmit_data = sign(randn(1, num_samples)); % BPSK modulated random data

%------------------------------------------------------------------------
% RECEIVED SIGNAL
%------------------------------------------------------------------------
received_signal = transmit_data.*fading_signal;
magnitude_received_signal = abs(received_signal);

%------------------------------------------------------------------------
% FIGURE(S)
%------------------------------------------------------------------------
figure(1)
X = (0 : 0.1 : 6);
[rayleigh_fading_sim, X_sim] = hist(magnitude_received_signal, X);
plot(X, rayleigh_fading_sim/sum(rayleigh_fading_sim), '-r', 'LineWidth', 2);
hold on;

sigma = 1/sqrt(2); % Standard deviation
rayleigh_fading_theory = (X./(sigma^2)).*exp((-X.^2)/(2*(sigma^2)));
plot(X, rayleigh_fading_theory/sum(rayleigh_fading_theory), '-b', 'LineWidth', 2);

grid on;
legend('Simulation', 'Theory');
xlabel('x');
ylabel('Rayleigh Distribution, p(x)');
title('Plot of Simulated and Theoretical Rayleigh Fading Wireless Channel');

figure(2)
t = (1 : num_samples);
plot(t, 10*log10(magnitude_fading_signal), 'LineWidth', 2);
xlabel('Sample Index');
ylabel('Signal Level in dB');
title('Signal Level of a Rayleigh Fading Wireless Channel in dB');

figure(3)
acorr_i = xcorr(fading_signal);
acorr_i = acorr_i / max(acorr_i);
plot(real(acorr_i(num_samples : num_samples+fd_max-1)), '-b', 'LineWidth', 2);
grid on;
xlabel('Sample Index');
ylabel('Autocorrelation Values');
title('Autocorrelation Function of Rayleigh Fading Wireless Channel Coefficients');

figure(4)
subplot(2,1,1)
plot(real(received_signal), imag(received_signal), 'b*')
grid on
legend('RX');
xlabel("Real")
ylabel("Imaginary")
title('Constellation of Received Signal with BPSK Modulation from Rayleigh Fading Wireless Channel')
subplot(2,1,2)
plot(real(transmit_data), imag(transmit_data), 'r*', 'LineWidth', 2)
grid on
legend('TX');
xlabel("Real")
ylabel("Imaginary")
title('Constellation of Transmit Signal with BPSK Modulation')
