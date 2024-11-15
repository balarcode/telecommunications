
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title     : Simulation of a Shadow Fading Wireless Channel
% Author    : balarcode
% Version   : 1.0
% Date      : 14th November 2024
% File Type : Matlab Script
% File Test : Verified on Matlab R2024b
% Comments  : Slow fading of a wireless channel can be modeled as a shadow
%             fading wireless channel.
%             It is used to model shadowing in a wireless channel i.e.
%             a large obstruction that overshadows the EM wave between the
%             transmitter and the receiver.
%             A channel experiencing slow (shadow) fading will have the 
%             channel impulse response changing at a rate much slower than 
%             the transmitted signal. In other words, coherence time will 
%             be quite large when compared to the symbol period (roughly in 
%             thousands of symbol periods) of the transmitted signal.
%
% All Rights Reserved.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

clear
close all

%-------------------------------------------------------------------------
% Simulation Parameter Initialization
%-------------------------------------------------------------------------
% Number of samples considered in the simulation
num_samples = 10^6;

% Standard deviation for shadow fading
sigma = sqrt(20);

%-------------------------------------------------------------------------
% Simulation of a Shadow Fading Wireless Channel
%-------------------------------------------------------------------------
shadow_fading_dB = randn(1, num_samples)*sigma; % Normal distribution (Power in dB)
shadow_fading_magnitude = 10.^(shadow_fading_dB/20); % Log-normal distribution (Power in watts)
% NOTE: The above is an exponential function with base 10.

%-------------------------------------------------------------------------
% TRANSMIT DATA
%-------------------------------------------------------------------------
transmit_data = sign(randn(1, num_samples)); % BPSK modulated random data

%-------------------------------------------------------------------------
% RECEIVED SIGNAL
%-------------------------------------------------------------------------
received_signal = transmit_data.*shadow_fading_magnitude;
magnitude_received_signal = abs(received_signal);

%-------------------------------------------------------------------------
% FIGURE(S)
%-------------------------------------------------------------------------
figure(1)
X = (0 : 0.1 : 6);
[shadow_fading_sim, X_sim] = hist(magnitude_received_signal, X);
plot(X, shadow_fading_sim/sum(shadow_fading_sim), '-b', 'LineWidth', 2);
hold on;
grid on;
xlabel('x');
ylabel('Log-Normal Distribution, p(x)');
title('Plot of Simulated Shadow Fading Wireless Channel');

figure(2)
t = (1 : num_samples);
plot(t, 10*log10(shadow_fading_magnitude), 'LineWidth', 2);
xlabel('Sample Index');
ylabel('Signal Level in dB');
title('Signal Level of a Shadow Fading Wireless Channel in dB');

figure(3)
subplot(2,1,1)
plot(real(received_signal), imag(received_signal), 'b*')
grid on
legend('RX');
xlabel("Real")
ylabel("Imaginary")
title('Constellation of Received Signal with BPSK Modulation from Shadow Fading Wireless Channel')
subplot(2,1,2)
plot(real(transmit_data), imag(transmit_data), 'r*', 'LineWidth', 2)
grid on
legend('TX');
xlabel("Real")
ylabel("Imaginary")
title('Constellation of Transmit Signal with BPSK Modulation')
