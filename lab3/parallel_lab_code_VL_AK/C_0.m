clc; clear;

% Open-loop system: G(s) = 1 / [s(s+2)(s+5)]
num = 1;
den = conv([1 0], conv([1 2], [1 5]));
G = tf(num, den);

%% Root locus plot
figure;
rlocus(G);
grid on;
title('Root Locus of L(s) = k / [s(s+2)(s+5)]');
hold on;

%% Programmatic search for kcrit by scanning k
k_vals = linspace(0, 100, 20001);   % fine grid
max_real = zeros(size(k_vals));

for i = 1:length(k_vals)
    k = k_vals(i);
    poles = roots([1 7 10 k]);   % characteristic: s^3 + 7s^2 + 10s + k
    max_real(i) = max(real(poles));
end

% Find k where max real part is closest to zero
[~, idx] = min(abs(max_real));
kcrit_est = k_vals(idx);

fprintf('Estimated kcrit from scan = %.6f\n', kcrit_est);

%% Exact poles at k = 70
kcrit = 70;
p70 = roots([1 7 10 kcrit]);

fprintf('Poles at k = 70:\n');
disp(p70);

% Overlay poles at k = 70 on root locus
plot(real(p70), imag(p70), 'ro', 'MarkerSize', 10, 'LineWidth', 2);

% mark the real-axis pole at k=70
legend('Root Locus', 'Poles at k = 70', 'Location', 'best');
