function B = dipole_field(r, m, mu0)
% DIPOLE_FIELD  Field of a point magnetic dipole m at the origin.
%   r : [N x 3] positions relative to the dipole, m : [1 x 3], B : [N x 3] (Tesla)
rn   = sqrt(sum(r.^2, 2));
rhat = r ./ rn;
mdr  = rhat * m(:);
B    = mu0/(4*pi) * (3*mdr.*rhat - m) ./ rn.^3;
end
