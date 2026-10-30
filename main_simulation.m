%% MAIN_SIMULATION  Coil on a wire, driven by AC current in a permanent-magnet field
%  Run this file. It (1) draws the 3D scene, (2) integrates the coil's
%  torsional dynamics, (3) animates the coil, (4) plots result graphs.
clear; close all; clc;

P = params_setup();

%% 1) Dynamics
rhs = @(t,y) coil_dynamics(t, y, P);
[t, y] = ode45(rhs, [0 P.tEnd], [0; 0], odeset('RelTol',1e-7,'AbsTol',1e-9));
theta = y(:,1);  omega = y(:,2);
I = P.I0*sin(2*pi*P.fDrive*t);
tau = arrayfun(@(k) magnetic_torque(theta(k), I(k), P), 1:numel(t))';

%% 2) 3D animation
fig3d = figure('Name','3D Simulation','Position',[100 100 800 600]);
ax = axes(fig3d);
H = draw_scene(P, ax);
visGain = 1.0;                      % increase to exaggerate the tilt visually
tt = linspace(0, P.tEnd, 240);
th_i = interp1(t, theta, tt);
for k = 1:numel(tt)
    H.setAngle(visGain*th_i(k));
    title(ax, sprintf('t = %.2f s   \\theta = %.1f°', tt(k), rad2deg(th_i(k))));
    drawnow limitrate;
end

%% 3) Graphs
figure('Name','Results','Position',[150 80 1100 650]);

subplot(2,3,1);
plot(t, I, 'Color',[0.8 0.2 0.1], 'LineWidth',1.5); grid on;
xlabel('t [s]'); ylabel('I [A]'); title('Coil current');

subplot(2,3,2);
plot(t, rad2deg(theta), 'b', 'LineWidth',1.5); grid on;
xlabel('t [s]'); ylabel('\theta [deg]'); title('Coil tilt angle');

subplot(2,3,3);
plot(rad2deg(theta), rad2deg(omega), 'Color',[0.1 0.5 0.3]); grid on;
xlabel('\theta [deg]'); ylabel('\omega [deg/s]'); title('Phase portrait');

% Frequency response (steady-state amplitude vs drive frequency)
subplot(2,3,4);
fs  = linspace(0.5, 8, 40);
amp = zeros(size(fs));
for k = 1:numel(fs)
    Pk = P; Pk.fDrive = fs(k);
    [tk, yk] = ode45(@(tt_,yy) coil_dynamics(tt_, yy, Pk), [0 4], [0;0]);
    amp(k) = max(abs(yk(tk > 2.5, 1)));
end
plot(fs, rad2deg(amp), 'o-', 'LineWidth',1.5); grid on; hold on;
xline(P.f0, '--r', 'f_0');
xlabel('Drive frequency [Hz]'); ylabel('Amplitude [deg]'); title('Frequency response');

% Torque vs angle at several currents
subplot(2,3,5); hold on; grid on;
thv = linspace(-pi/4, pi/4, 101);
for Ik = [-P.I0 0 P.I0]
    plot(rad2deg(thv), arrayfun(@(a) magnetic_torque(a, Ik, P), thv), 'LineWidth',1.5, ...
         'DisplayName', sprintf('I = %.2f A', Ik));
end
xlabel('\theta [deg]'); ylabel('\tau_x [N m]'); title('Magnetic torque'); legend('Location','best');

% Field at the coil centre versus magnet spacing (point-dipole model)
subplot(2,3,6);
sep = linspace(0.048, 0.10, 80);
Bs = zeros(size(sep));
for k = 1:numel(sep)
    Bk = dipole_field([0 sep(k) 0], P.mMag, P.mu0);   % one magnet; two magnets add equally
    Bs(k) = 2*Bk(2);
end
plot(sep*1000, 1000*Bs, 'm', 'LineWidth',1.5); grid on; hold on;
plot(P.magY*1000, 1000*magnet_field(P.coilCenter, P)*[0;1;0], 'ko', 'MarkerFaceColor','k');
xlabel('Magnet distance from axle [mm]'); ylabel('B at coil centre [mT]'); title('Field vs magnet spacing');

sgtitle('Coil / magnet torsional simulation');
