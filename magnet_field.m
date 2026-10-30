function B = magnet_field(pts, P)
% MAGNET_FIELD  Total field [N x 3] (Tesla) of the two side magnets (dipole model)
% at points pts [N x 3].
B = zeros(size(pts));
for k = 1:2
    B = B + dipole_field(pts - P.magPos(k,:), P.mMag, P.mu0);
end
end
