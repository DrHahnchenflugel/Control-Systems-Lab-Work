figure
tiledlayout(3,1,'TileSpacing','compact','Padding','compact')

nexttile
plot(out.timespace, out.thermo_in, 'LineWidth', 1.5)
ylim([-4 4])
grid on
ylabel('Input')
xlabel('Time')
title('A.1 Thermostat plot')

nexttile
plot(out.timespace, out.roomtemp, 'LineWidth', 1.5)
grid on
ylabel('Room temp')
xlabel('Time')

nexttile
plot(out.timespace, out.heatflow, 'LineWidth', 1.5)
grid on
ylabel('Heat flow')
xlabel('Time')
