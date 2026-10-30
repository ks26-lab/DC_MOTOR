function tau_x = magnetic_torque(theta, I, P)
% MAGNETIC_TORQUE  Torque about the wire axis (x) on the coil carrying current I,
% tilted by angle theta, sitting between the two side magnets.
B = magnet_field(P.coilCenter, P);             % total field at the coil centre
n = [0, -sin(theta), cos(theta)];              % coil normal after rotation about x
mc = P.coilN * I * P.coilArea * n;             % coil magnetic moment
tau = cross(mc, B);
tau_x = tau(1);
end
