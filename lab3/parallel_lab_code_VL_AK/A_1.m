clc; clear;

% Define Numerator & Denominator
num = 1000 * [1 5]; % (s + 5)
den1 = [1 20];      % (s + 20)
den2 = [1 100];     % (s + 100)
den3 = [1 0.4 1.04];% (s^2 + 0.4s + 1.04)

% Multiply denominator polynomials
den_full = conv(conv(den1, den2), den3);

% Create transfer function
T = tf(num, den_full);

% Bode Plots
bode (T)
grid on;
