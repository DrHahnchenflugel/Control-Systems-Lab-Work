clc; clear;

% Plant
num = 1;
den = conv([1 0], conv([1 2], [1 5]));   % s(s+2)(s+5)
G = tf(num, den);

% Frequency range
w = 1:0.1:10;

% Two loop gains
L1 = 1 * G;
L2 = 100 * G;

% Nyquist plot
figure;
nyquist(L1, w);
hold on;
nyquist(L2, w);
grid on;
legend('k = 1', 'k = 100', 'Location', 'best');
title('Nyquist Plot of Loop Gain kG(s)');
