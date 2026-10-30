function dy = coil_dynamics(t, y, P)
% COIL_DYNAMICS  ODE right-hand side. State y = [theta; omega].
%   J*theta'' + c*theta' + kappa*theta = tau_magnetic(theta, I(t))
I  = P.I0 * sin(2*pi*P.fDrive*t);
tau = magnetic_torque(y(1), I, P);
dy = [y(2);
      (tau - P.c*y(2) - P.kappa*y(1)) / P.J];
end
