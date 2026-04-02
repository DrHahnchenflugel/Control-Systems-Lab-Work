clear; clc; close all;

DA = load('/home/drhahnchenflugel/Github/Control-Systems-Lab-Work/lab3/data_v3/g22.dat');
DB = load('/home/drhahnchenflugel/Github/Control-Systems-Lab-Work/lab3/data_v3/g23.dat');

tA = DA(:,1); rA = DA(:,2); yA = DA(:,3);
tB = DB(:,1); rB = DB(:,2); yB = DB(:,3);

figure;
hold on; grid on;

plot(tA, rA, 'k--', 'LineWidth', 1.2);   % reference
plot(tA, yA, 'b',  'LineWidth', 1.5);    % P
plot(tB, yB, 'r',  'LineWidth', 1.5);    % PD

xlabel('Time (s)');
ylabel('Signal');
title('Saturation: PID vs PID+A');
legend('Reference', 'PID Output', 'PID+A Output', 'Location', 'best');
