clear; clc; close all;

%% Load data
% Assumes 3 columns:
% col 1 = time
% col 2 = reference input
% col 3 = servo output
data = load('B1-1.dat');

t = data(:,1);
r = data(:,2);
y = data(:,3);

%% User settings
tol_settle = 0.02;      % 2% settling band
tail_frac   = 0.10;     % use last 10% of each half-cycle for ess estimate
min_pts_tail = 5;       % minimum number of samples in tail average
make_plot = true;

%% Find each square-wave transition
edge_idx = find(diff(r) ~= 0);   % step occurs between k and k+1

nSteps = numel(edge_idx);

% Preallocate
step_start_time = nan(nSteps,1);
step_end_time   = nan(nSteps,1);
r_initial       = nan(nSteps,1);
r_final         = nan(nSteps,1);
step_amp        = nan(nSteps,1);

rise_time       = nan(nSteps,1);
settling_time   = nan(nSteps,1);
percent_OS      = nan(nSteps,1);
ss_error        = nan(nSteps,1);

for i = 1:nSteps
    k0 = edge_idx(i) + 1;   % first sample after the reference changes

    % End this segment right before next edge, or at end of record
    if i < nSteps
        k1 = edge_idx(i+1);
    else
        k1 = length(t);
    end

    tt = t(k0:k1);
    yy = y(k0:k1);
    rr = r(k0:k1);

    y0 = y(k0-1);       % actual output right before step
    r0 = r(k0-1);       % previous reference
    rf = r(k0);         % new reference
    A  = rf - r0;       % step amplitude

    step_start_time(i) = t(k0);
    step_end_time(i)   = t(k1);
    r_initial(i)       = r0;
    r_final(i)         = rf;
    step_amp(i)        = A;

    if A == 0
        continue;
    end

    sgn = sign(A);
    Aabs = abs(A);

    %% Rise time (10% to 90% of THIS step)
    y10 = r0 + 0.10*A;
    y90 = r0 + 0.90*A;

    idx10 = find(sgn*(yy - y10) >= 0, 1, 'first');
    idx90 = find(sgn*(yy - y90) >= 0, 1, 'first');

    if ~isempty(idx10) && ~isempty(idx90) && idx90 >= idx10
        rise_time(i) = tt(idx90) - tt(idx10);
    end

    %% Percent overshoot for THIS step
    % Measure peak excursion beyond the target in the step direction.
    if sgn > 0
        y_peak = max(yy);
        OS_abs = max(0, y_peak - rf);
    else
        y_peak = min(yy);
        OS_abs = max(0, rf - y_peak);
    end
    percent_OS(i) = 100 * OS_abs / Aabs;

    %% Settling time for THIS step
    % First time it enters the ±2% band around the CURRENT target
    % and stays there until the next square-wave transition.
    band = tol_settle * Aabs;
    inband = abs(yy - rf) <= band;

    settle_idx = NaN;
    for m = 1:length(inband)
        if all(inband(m:end))
            settle_idx = m;
            break;
        end
    end

    if ~isnan(settle_idx)
        settling_time(i) = tt(settle_idx) - tt(1);
    end

    %% Steady-state error for THIS half-cycle
    % Use average of the last part of the segment, not the very last sample.
    nTail = max(min_pts_tail, round(tail_frac * length(yy)));
    y_ss_est = mean(yy(end-nTail+1:end));
    ss_error(i) = rf - y_ss_est;   % signed error
end

%% Summary values
% For lab-style comparison, these are usually the most useful:
OSmax = max(percent_OS, [], 'omitnan');
tr_avg = mean(rise_time, 'omitnan');
tr_max = max(rise_time, [], 'omitnan');
ts_avg = mean(settling_time, 'omitnan');
ts_max = max(settling_time, [], 'omitnan');
ess_avg_abs = mean(abs(ss_error), 'omitnan');
ess_max_abs = max(abs(ss_error), [], 'omitnan');

%% Display per-step table
Results = table((1:nSteps).', step_start_time, step_end_time, r_initial, r_final, ...
    step_amp, rise_time, settling_time, percent_OS, ss_error, ...
    'VariableNames', {'StepNo','tStart','tEnd','r0','rf','Amp','tr','ts','PercentOS','ess'});

disp(Results);

fprintf('\n===== OVERALL SUMMARY =====\n');
fprintf('%%OSmax           = %.3f %%\n', OSmax);
fprintf('Rise time avg    = %.4f s\n', tr_avg);
fprintf('Rise time worst  = %.4f s\n', tr_max);
fprintf('Settle time avg  = %.4f s\n', ts_avg);
fprintf('Settle time worst= %.4f s\n', ts_max);
fprintf('|ess| avg        = %.4f deg\n', ess_avg_abs);
fprintf('|ess| max        = %.4f deg\n', ess_max_abs);

%% Optional plots
if make_plot
    figure;
    plot(t, r, 'k--', 'LineWidth', 1.2); hold on;
    plot(t, y, 'b', 'LineWidth', 1.5);
    xlabel('Time (s)');
    ylabel('Angle (deg)');
    legend('Reference','Output','Location','best');
    title('Servo response to repeated square wave');
    grid on;

    % Mark detected step start times
    xline(step_start_time, ':r');
end
