figure
plot(out.simout1, out.simout, 'LineWidth', 1.5)
ylim([-4 4])
grid on
xlabel('Time')
ylabel('f_1')
title('A.1 Thermostat plot')
legend({'Input','Output'}, 'Location','best')
