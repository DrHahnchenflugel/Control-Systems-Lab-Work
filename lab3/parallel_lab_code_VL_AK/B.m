clc; clear;

K = 10;
wn = 1.5;
zeta = 0.707;
z = 12;

num = K * [1/z 1];
den = [1/wn^2 2*zeta/wn 1];

T_est = tf(num, den);

bode(T_est)
grid on
