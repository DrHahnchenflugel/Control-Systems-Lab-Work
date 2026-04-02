clear; clc; close all;
pkg load control %% REMOVE IN MATLAB!!!

%% Load data
% Assumes 3 columns:
% col 1 = time
% col 2 = reference input
% col 3 = servo output
data = load('/home/drhahnchenflugel/Github/Control-Systems-Lab-Work/lab3/data_v3/g23.dat');

t = data(:,1);
r = data(:,2);
y = data(:,3);

%% User settings
tol_settle   = 0.02;    % 2% settling band
tail_frac    = 0.10;    % use last 10% of each half-cycle for ess estimate
min_pts_tail = 5;       % minimum number of samples in tail average
make_plot    = true;

%% Find each square-wave transition
edge_idx = find(diff(r) ~= 0);   % step occurs between k and k+1
nSteps = numel(edge_idx);

%% Preallocate
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

    y0 = y(k0-1); %#ok<NASGU>   % actual output right before step
    r0 = r(k0-1);               % previous reference
    rf = r(k0);                 % new reference
    A  = rf - r0;               % step amplitude

    step_start_time(i) = t(k0);
    step_end_time(i)   = t(k1);
    r_initial(i)       = r0;
    r_final(i)         = rf;
    step_amp(i)        = A;

    if A == 0
        continue;
    end

    sgn  = sign(A);
    Aabs = abs(A);

    %% Rise time (10% to 90% of this step)
    y10 = r0 + 0.10*A;
    y90 = r0 + 0.90*A;

    idx10 = find(sgn*(yy - y10) >= 0, 1, 'first');
    idx90 = find(sgn*(yy - y90) >= 0, 1, 'first');

    if ~isempty(idx10) && ~isempty(idx90) && idx90 >= idx10
        rise_time(i) = tt(idx90) - tt(idx10);
    end

    %% Percent overshoot for this step
    if sgn > 0
        y_peak = max(yy);
        OS_abs = max(0, y_peak - rf);
    else
        y_peak = min(yy);
        OS_abs = max(0, rf - y_peak);
    end
    percent_OS(i) = 100 * OS_abs / Aabs;

    %% Settling time for this step
    % First time it enters the ±2% band around the current target
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

    %% Steady-state error for this half-cycle
    nTail = max(min_pts_tail, round(tail_frac * length(yy)));
    nTail = min(nTail, length(yy));   % safety
    y_ss_est = mean(yy(end-nTail+1:end));
    ss_error(i) = rf - y_ss_est;      % signed error
end

%% Summary values (Octave-safe NaN handling)
valid_OS = percent_OS(~isnan(percent_OS));
valid_tr = rise_time(~isnan(rise_time));
valid_ts = settling_time(~isnan(settling_time));
valid_ess = abs(ss_error(~isnan(ss_error)));

if isempty(valid_OS),  OSmax = NaN; else OSmax = max(valid_OS); end
if isempty(valid_tr),  tr_avg = NaN; tr_max = NaN;
else
    tr_avg = mean(valid_tr);
    tr_max = max(valid_tr);
end

if isempty(valid_ts),  ts_avg = NaN; ts_max = NaN;
else
    ts_avg = mean(valid_ts);
    ts_max = max(valid_ts);
end

if isempty(valid_ess), ess_avg_abs = NaN; ess_max_abs = NaN;
else
    ess_avg_abs = mean(valid_ess);
    ess_max_abs = max(valid_ess);
end

%% Display per-step results without table()
fprintf('\n================ PER-STEP RESULTS ================\n');
fprintf('%5s %10s %10s %8s %8s %8s %10s %10s %12s %10s\n', ...
    'Step', 'tStart', 'tEnd', 'r0', 'rf', 'Amp', 'tr', 'ts', '%OS', 'ess');
fprintf('%5s %10s %10s %8s %8s %8s %10s %10s %12s %10s\n', ...
    '----', '------', '----', '--', '--', '---', '--', '--', '---', '---');

for i = 1:nSteps
    fprintf('%5d %10.4f %10.4f %8.3f %8.3f %8.3f %10.4f %10.4f %12.3f %10.4f\n', ...
        i, ...
        step_start_time(i), ...
        step_end_time(i), ...
        r_initial(i), ...
        r_final(i), ...
        step_amp(i), ...
        rise_time(i), ...
        settling_time(i), ...
        percent_OS(i), ...
        ss_error(i));
end

fprintf('\n===== OVERALL SUMMARY =====\n');
fprintf('%%OSmax            = %.3f %%\n', OSmax);
fprintf('Rise time avg     = %.4f s\n', tr_avg);
fprintf('Rise time worst   = %.4f s\n', tr_max);
fprintf('Settle time avg   = %.4f s\n', ts_avg);
fprintf('Settle time worst = %.4f s\n', ts_max);
fprintf('|ess| avg         = %.4f deg\n', ess_avg_abs);
fprintf('|ess| max         = %.4f deg\n', ess_max_abs);

%% Optional plots
if make_plot
    figure;
    plot(t, r, 'k--', 'LineWidth', 1.2); hold on;
    plot(t, y, 'b', 'LineWidth', 1.5);
    xlabel('Time (s)');
    ylabel('Angle (deg)');
    legend('Reference', 'Output', 'Location', 'best');
    title('Servo response to repeated square wave');
    grid on;

    % Octave-safe vertical lines instead of xline()
    yl = ylim;
    for i = 1:length(step_start_time)
        if ~isnan(step_start_time(i))
            line([step_start_time(i) step_start_time(i)], yl, ...
                'Color', 'r', 'LineStyle', ':');
        end
    end
end
