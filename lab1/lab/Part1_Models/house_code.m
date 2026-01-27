figure
tiledlayout(3,1,'TileSpacing','compact','Padding','compact')

nexttile
plot(out.timespace, out.heatflow, 'LineWidth', 1.5)
ylim([-4 4])
grid on
ylabel('Heatflow')
xlabel('Time')
title('A.1 Thermostat plot')

nexttile
plot(out.timespace, out.outdoor_temp, 'LineWidth', 1.5)
grid on
ylabel('Outdoor temp')
xlabel('Time')

nexttile
plot(out.timespace, out.house_out, 'LineWidth', 1.5)
grid on
ylabel('House temperature')
xlabel('Time')
