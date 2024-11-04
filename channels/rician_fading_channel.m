
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title     : Simulation of a Rician Fading Wireless Channel
% Author    : balarcode
% Version   : 1.0
% Date      : 3rd November 2024
% File Type : Matlab Script
% File Test : Verified on Matlab R2024b
% Comments  : Short-term fast fading of a wireless channel
%             can be modeled as a Rician fading channel.
%             The channel includes a dominant line of sight (LOS) component 
%             between transmitter and receiver as well as multipath propagation
%             of a transmitted EM wave through multiple scatterers in the
%             vicinity of the wireless receiver.
%             Rician fading wireless channel is used to model both indoor
%             and outdoor propagation channels including channels for
%             cellular communication and satellite communication.
%             Rayleigh fading is considered a special case of Rician fading
%             when there is no line of sight component in the received signal 
%             at the wireless receiver.
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

% Symbol period (To be taken to be less than the Doppler period)
Ts = 0.1/fd_max;

fs = 1/Ts;

% Number of samples considered in the simulation
num_samples = 10^6;

M = 32;
n = 1 : M;
N = 4 * M;

% Initialize r_i and r_q to all zeros
r_i = zeros(1, num_samples); % Returns a vector of order 1 x num_samples with elements being zeros
r_q = r_i;

%-------------------------------------------------------------------------
% Simulation of a Rician Fading Wireless Channel
%-------------------------------------------------------------------------
fc = cos(2 * pi * (n-0.5)/N);

% Doppler frequency
fn = fd_max * cos(2 * pi * (n-0.5)/N); 
% NOTE: Since the Doppler frequency is very small compared to the carrier frequency,
%       the electric field components can be modeled as a narrow band random process.

% angle_n is the angle of the nth scattered wave arriving at the receiver w.r.t the direction of motion of the receiver
% NOTE: The scattered waves arrive at a uniform distribution angle.
angle_n = pi * n/(M); 

% 'alpha_n' is a real random variable representing the amplitude of LOS and scattered waves
H = hadamard(M);
alpha_n = H;

% The random phase of the LOS and scattered waves are statistically independent and
% uniformly distributed in (0, 2*pi)
theta = 2 * pi * rand(1, M);
% NOTE: Random phase is applied to both LOS and scattered waves under the
% assumption that the wireless transmitter and/or receiver are continuously in motion.

m = 1 : num_samples;

% Phase of the nth scattered wave arriving at the receiver with 
% Doppler shift included = (2*pi*fn*t)+theta; where 't' is sampled at 'm*Ts'
for idx = 1 : M
    r_i(m) = r_i(m) + ( alpha_n(idx) * cos(2*pi*fc(idx)*m*Ts+theta(idx)) ) + ( alpha_n(idx) * cos(angle_n(idx)) * cos(2*pi*fn(idx)*m*Ts+theta(idx)) );
    r_q(m) = r_q(m) + ( alpha_n(idx) * cos(2*pi*fc(idx)*m*Ts+theta(idx)) ) + ( alpha_n(idx) * sin(angle_n(idx)) * cos(2*pi*fn(idx)*m*Ts+theta(idx)) );
end
% NOTE-1: r_i and r_q represent the Gaussian random variables for the in-phase and 
%         quadrature-phase of the resultant Electric Field at the wireless receiver.
%         These two Gaussian random variables are independent and identically distributed.
% NOTE-2: Jakes Method uses Sum of Sinusoids to obtain the Gaussian random
%         variables with Doppler shift and angle of arrival included.
% NOTE-3: The second summand above represents the dominant line of sight path/wave.

% Complex baseband received signal from a Rician fading channel
received_signal = (r_i + 1i*r_q) / (sqrt(2/M)*(2/3));

% NOTE: The distribution of magnitude of the received signal follows a 
% Rician or Rice probability distribution.
magnitude_received_signal = abs(received_signal);

%------------------------------------------------------------------------
% FIGURE(S)
%------------------------------------------------------------------------
figure(1)
[rician_fading_sim, X_sim] = hist(magnitude_received_signal, N);
plot(X_sim, rician_fading_sim'/(N*0.29), '-r', 'LineWidth', 2);
hold on;

std_dev = 25;
X = (0 : N);
rician_fading_theory = 3e4*(X./(std_dev^2)).*exp((-X.^2-1)/(2*(std_dev^2))).*besselj(0,(X./(std_dev^2)));
plot(rician_fading_theory, '-b', 'LineWidth', 2);
% NOTE: Bessel function is of first kind with zeroth order.

axis([0 100 0 1000]);
grid on;
legend('Simulation', 'Theory');
xlabel('x');
ylabel('Rician Distribution, p(x)');
title('Plot of Simulated and Theoretical Rician Fading Wireless Channel');

figure(2)
t = (1 : num_samples);
plot(t, 10*log10(magnitude_received_signal));
xlabel('Samples');
ylabel('Received Signal Level in dB');
title('Received Signal Level in dB');
