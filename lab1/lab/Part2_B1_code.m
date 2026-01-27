t = out.time;
sig = out.Fstep;
u = sig(:,1);
y = sig(:,2);

% --- Find step time t0 and step amplitude A ---
du = diff(u);
idx0 = find(abs(du) > 0.5*max(abs(du)), 1, 'first') + 1;  % step edge index
t0 = t(idx0);

u0 = mean(u(1:idx0-1));                 % pre-step level
u1 = mean(u(idx0:min(idx0+10,end)));    % post-step level (early)
A  = u1 - u0;

% --- Initial and final output values ---
y0 = mean(y(1:idx0-1));                 % pre-step output
yss = mean(y(round(0.9*end):end));      % steady-state output (last 10%)
dy  = yss - y0;

% --- DC gain ---
k = dy / A;

% --- Time constant (63.2% point) ---
y_tau = y0 + 0.632 * dy;

idx_tau = find(t >= t0 & ((dy>=0 & y >= y_tau) | (dy<0 & y <= y_tau)), 1, 'first');
tau = t(idx_tau) - t0;

fprintf('DC gain k = %.4f\n', k);
fprintf('Time constant tau = %.4f s\n', tau);
