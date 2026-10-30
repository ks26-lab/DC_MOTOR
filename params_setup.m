function P = params_setup()
% PARAMS_SETUP  Geometry and physical parameters (SI units, metres).

% ---------- Geometry ----------
P.board   = [0.36 0.24 0.012];      % [Lx Ly Lz], top surface at z = 0
P.postX   = 0.14;                   % posts at x = +/- postX, y = 0
P.postH   = 0.100;                  % post height
P.postR   = 0.0025;                 % post radius
P.ringR   = 0.007;                  % eyelet ring radius
P.wireZ   = 0.095;                  % height of the wire between the eyelets
P.coilCenter = [0 0 P.wireZ];
P.coilRo  = 0.045;                  % coil outer radius
P.coilRi  = 0.032;                  % coil inner radius
P.coilN   = 12;                     % number of turns (about 3 m of 26 SWG wire)
P.boxSize = [0.04 0.03 0.02];       % terminal boxes
P.boxPos  = [-0.14 -0.07 P.boxSize(3)/2;
              0.14 -0.07 P.boxSize(3)/2];

% ---------- Two rectangular magnets floating in the air, one each side of the coil ----------
P.magSize = [0.020 0.006 0.012];    % N35 block 20 x 12 x 6 mm: [x y z]; thickness (y, 6 mm) is the magnetised direction
P.magY    = 0.053;                  % magnet centres at y = -magY and +magY (inner faces 5 mm outside the coil)
P.magPos  = [0 -P.magY P.wireZ;     % left (y<0) magnet centre
             0  P.magY P.wireZ];    % right (y>0) magnet centre
P.mu0     = 4*pi*1e-7;
P.Mag     = 1.2/P.mu0;              % N35 magnetisation [A/m] (Br about 1.2 T)
P.magVol  = prod(P.magSize);
P.mMag    = P.Mag*P.magVol*[0 1 0]; % both dipole moments along +y -> field across the gap along +y

% ---------- Coil mechanics (torsional oscillator about the wire / x-axis) ----------
P.coilMass = 0.0044;                              % kg (3 m of 26 SWG copper)
P.J     = 0.5*P.coilMass*((P.coilRo+P.coilRi)/2)^2;   % ring inertia about a diameter
P.f0    = 3.0;                                    % natural frequency [Hz]
P.kappa = P.J*(2*pi*P.f0)^2;                      % wire torsion stiffness [N m/rad]
P.zeta  = 0.05;                                   % damping ratio
P.c     = 2*P.zeta*sqrt(P.kappa*P.J);             % viscous damping [N m s/rad]
P.coilArea = pi*((P.coilRo+P.coilRi)/2)^2;        % mean turn area

% ---------- Drive ----------
P.I0     = 0.2;                                   % current amplitude [A]
P.fDrive = 3.0;                                   % drive frequency [Hz]
P.tEnd   = 4.0;                                   % simulation time [s]
end
