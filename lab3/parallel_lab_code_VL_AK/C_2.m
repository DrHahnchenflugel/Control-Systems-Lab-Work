clc; clear;

%% System
num = 1;
den = conv([1 0], conv([1 2], [1 5]));   % s(s+2)(s+5)
G = tf(num, den);

k1 = 1;
k2 = 100;

L1 = k1 * G;
L2 = k2 * G;

w = 1:0.1:10;

%% Frequency responses for Nyquist plot
resp1 = squeeze(freqresp(L1, w));
resp2 = squeeze(freqresp(L2, w));

%% Margins
[gm1, pm1, wg1, wp1] = margin(L1);
[gm2, pm2, wg2, wp2] = margin(L2);

fprintf('k = 1:\n');
fprintf('  GM = %.4f (%.2f dB)\n', gm1, 20*log10(gm1));
fprintf('  PM = %.2f deg\n', pm1);
fprintf('  Wg = %.4f rad/s, Wp = %.4f rad/s\n\n', wg1, wp1);

fprintf('k = 100:\n');
fprintf('  GM = %.4f (%.2f dB)\n', gm2, 20*log10(gm2));
fprintf('  PM = %.2f deg\n', pm2);
fprintf('  Wg = %.4f rad/s, Wp = %.4f rad/s\n\n', wg2, wp2);

%% Plot Nyquist manually
figure; hold on; grid on;

% k = 1
plot(real(resp1), imag(resp1), 'b', 'LineWidth', 1.5, 'DisplayName', 'k = 1');
plot(real(resp1), -imag(resp1), 'b--', 'HandleVisibility', 'off');

% k = 100
plot(real(resp2), imag(resp2), 'r', 'LineWidth', 1.5, 'DisplayName', 'k = 100');
plot(real(resp2), -imag(resp2), 'r--', 'HandleVisibility', 'off');

% Critical point
plot(-1, 0, 'kx', 'MarkerSize', 10, 'LineWidth', 2, ...
    'DisplayName', 'Critical Point (-1,0)');

%% Mark phase margin points (gain crossover points, |L| = 1)
if wp1 >= min(w) && wp1 <= max(w)
    p_pm1 = squeeze(freqresp(L1, wp1));
    plot(real(p_pm1), imag(p_pm1), 'bo', 'MarkerSize', 8, 'LineWidth', 2, ...
        'DisplayName', 'PM point (k=1)');
end

if wp2 >= min(w) && wp2 <= max(w)
    p_pm2 = squeeze(freqresp(L2, wp2));
    plot(real(p_pm2), imag(p_pm2), 'ro', 'MarkerSize', 8, 'LineWidth', 2, ...
        'DisplayName', 'PM point (k=100)');
end

%% Mark gain margin points (phase crossover points, angle = -180 deg)
if wg1 >= min(w) && wg1 <= max(w)
    p_gm1 = squeeze(freqresp(L1, wg1));
    plot(real(p_gm1), imag(p_gm1), 'bs', 'MarkerSize', 8, 'LineWidth', 2, ...
        'DisplayName', 'GM point (k=1)');
end

if wg2 >= min(w) && wg2 <= max(w)
    p_gm2 = squeeze(freqresp(L2, wg2));
    plot(real(p_gm2), imag(p_gm2), 'rs', 'MarkerSize', 8, 'LineWidth', 2, ...
        'DisplayName', 'GM point (k=100)');
end

xlabel('Real Axis');
ylabel('Imaginary Axis');
title('Nyquist Plot of Loop Gain kG(s)');
legend('Location', 'best');
axis equal;
