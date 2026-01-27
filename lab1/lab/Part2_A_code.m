figure;

subplot(5,1,1);
plot(out.time_interval, out.step);
ylabel('step');
title('Variables vs Time');

subplot(5,1,2);
plot(out.time_interval, out.f1);
ylabel('f_1');
title('Variables vs Time');

subplot(5,1,3);
plot(out.time_interval, out.f2);
ylabel('f_2');

subplot(5,1,4);
plot(out.time_interval, out.f3);
ylabel('f_3');

subplot(5,1,5);
plot(out.time_interval, out.f4);
ylabel('f_4');
xlabel('Time');