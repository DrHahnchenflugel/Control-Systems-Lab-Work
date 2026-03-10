clear; clc;

filename = '/home/drhahnchenflugel/Downloads/B1-1.dat';
data = dlmread(filename);

t    = data(:,1);
goal = data(:,2);
y    = data(:,3);

%% parameters
settleBand = 0.02;
riseLow  = 0.10;
riseHigh = 0.90;

%% detect goal changes
goalChange = find(abs(diff(goal)) > 1e-6) + 1;

segStart = [1; goalChange];
segEnd   = [goalChange-1; length(t)];

nSeg = length(segStart);

%% result arrays
OS      = zeros(nSeg,1);
t_rise  = zeros(nSeg,1);
t_settle= zeros(nSeg,1);
ess     = zeros(nSeg,1);

for k = 1:nSeg

    i1 = segStart(k);
    i2 = segEnd(k);

    tk = t(i1:i2);
    yk = y(i1:i2);
    gk = goal(i1:i2);

    g_final = gk(1);

    if k == 1
        g_initial = yk(1);
    else
        g_initial = goal(segStart(k)-1);
    end

    delta = g_final - g_initial;

    if abs(delta) < 1e-6
        continue
    end

    %% normalize response
    yn = (yk - g_initial) / delta;

    %% rise time
    idx10 = find(yn >= riseLow,1);
    idx90 = find(yn >= riseHigh,1);

    if ~isempty(idx10) && ~isempty(idx90)
        t_rise(k) = tk(idx90) - tk(idx10);
    else
        t_rise(k) = NaN;
    end

    %% overshoot
    maxYn = max(yn);
    OS(k) = max(0,(maxYn-1)*100);

    %% settling time
    band = abs(yn-1) <= settleBand;
    t_settle(k) = NaN;

    for m = 1:length(band)
        if all(band(m:end))
            t_settle(k) = tk(m) - tk(1);
            break
        end
    end

    %% steady state error
    ess(k) = abs(g_final - yk(end));

end

%% remove first segment (usually unreliable)
valid = 2:nSeg;

fprintf('\nAverage results:\n')
fprintf('OS_max   = %.3f %%\n', mean(OS(valid)))
fprintf('t_rise   = %.3f s\n', mean(t_rise(valid)))
fprintf('t_settle = %.3f s\n', mean(t_settle(valid)))
fprintf('ess      = %.3f deg\n', mean(ess(valid)))

fprintf('\nWorst case:\n')
fprintf('OS_max   = %.3f %%\n', max(OS(valid)))
fprintf('t_rise   = %.3f s\n', max(t_rise(valid)))
fprintf('t_settle = %.3f s\n', max(t_settle(valid)))
fprintf('ess      = %.3f deg\n', max(ess(valid)))

%% plot
figure
plot(t,goal,'k--','linewidth',1.5)
hold on
plot(t,y,'b','linewidth',1.5)
grid on
xlabel('Time')
ylabel('Angle (deg)')
legend('Goal','Actual')
title('Step Tracking')
