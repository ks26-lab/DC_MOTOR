function H = draw_scene(P, ax)
% DRAW_SCENE  Builds the 3D setup: base plate, terminal boxes, posts with eyelets,
% wire, spiral coil (rotatable about the wire) and two floating block magnets.
% Returns handle struct H; use H.setAngle(theta) to rotate the coil.
if nargin < 2, ax = gca; end
hold(ax, 'on');
bg = [0.93 0.95 0.98];
set(ax.Parent, 'Color', bg);
set(ax, 'Color', bg);

% ---- Colour scheme ----
cBoard  = [0.20 0.25 0.30];   % dark slate
cBox    = [0.45 0.30 0.70];   % violet
cCable1 = [0.10 0.60 0.30];   % green
cCable2 = [0.95 0.75 0.10];   % yellow
cPost   = [0.75 0.78 0.80];   % silver
cWire   = [0.90 0.75 0.20];   % gold
cCoil   = [0.10 0.70 0.75];   % cyan-teal
cNorth  = [0.90 0.30 0.15];   % magnet N pole
cSouth  = [0.30 0.55 0.90];   % magnet S pole

% ---- Base plate ----
draw_box(ax, [0 0 -P.board(3)/2], P.board, cBoard);

% ---- Terminal boxes + cables ----
cab = {cCable1, cCable2};
sgn = [-1 1];
for k = 1:2
    draw_box(ax, P.boxPos(k,:), P.boxSize, cBox);
    p0 = [P.boxPos(k,1) + sgn(k)*0.015, P.boxPos(k,2), P.boxSize(3)];
    p1 = [sgn(k)*P.postX, 0, 0];
    plot3(ax, [p0(1) p1(1)], [p0(2) p1(2)], [p0(3) p1(3)], 'Color', cab{k}, 'LineWidth', 3);
end

% ---- Posts and eyelet rings ----
phi = linspace(0, 2*pi, 40);
for s = sgn
    [X,Y,Z] = cylinder(P.postR, 16);
    surf(ax, X + s*P.postX, Y, Z*P.postH, 'FaceColor', cPost, 'EdgeColor', 'none');
    plot3(ax, s*P.postX*ones(size(phi)), P.ringR*cos(phi), ...
          P.wireZ + P.ringR*sin(phi), 'Color', cPost*0.8, 'LineWidth', 2);
end

% ---- Wire ----
plot3(ax, [-P.postX P.postX], [0 0], [P.wireZ P.wireZ], 'Color', cWire, 'LineWidth', 1.5);

% ---- Coil (child of hgtransform so it can tilt about the x-axis wire) ----
hg = hgtransform('Parent', ax);
H.coil = hg;
rr = linspace(P.coilRi, P.coilRo, 20);
tt = linspace(0, 2*pi, 80);
[R, T] = meshgrid(rr, tt);
surf(R.*cos(T), R.*sin(T), zeros(size(R)), 'Parent', hg, ...
     'FaceColor', cCoil, 'EdgeColor', 'none', 'FaceAlpha', 0.55);
nPts = P.coilN*60;
th = linspace(0, 2*pi*P.coilN, nPts);
r  = linspace(P.coilRi, P.coilRo, nPts);
plot3(r.*cos(th), r.*sin(th), zeros(1,nPts), 'Parent', hg, 'Color', cCoil*0.6, 'LineWidth', 0.5);
H.setAngle = @(theta) set(hg, 'Matrix', ...
    makehgtform('translate', P.coilCenter) * makehgtform('xrotate', theta));
H.setAngle(0);

% ---- Two rectangular magnets floating in the air (N half red, S half blue) ----
% Both moments point along +y: left magnet has its N half toward the coil,
% right magnet has its S half toward the coil.
half = [P.magSize(1) P.magSize(2)/2 P.magSize(3)];
off  = P.magSize(2)/4;
% left magnet (y<0): S half outside (-y), N half inside (+y)
draw_box(ax, P.magPos(1,:) + [0 -off 0], half, cSouth);
draw_box(ax, P.magPos(1,:) + [0  off 0], half, cNorth);
% right magnet (y>0): S half inside (-y), N half outside (+y)
draw_box(ax, P.magPos(2,:) + [0 -off 0], half, cSouth);
draw_box(ax, P.magPos(2,:) + [0  off 0], half, cNorth);

% ---- View / lighting ----
axis(ax, 'equal'); axis(ax, 'off');
view(ax, 35, 20);
camlight(ax, 'headlight'); lighting(ax, 'gouraud');
xlim(ax, [-0.2 0.2]); ylim(ax, [-0.14 0.14]); zlim(ax, [-0.02 0.14]);
end

function draw_box(ax, c, s, col)
v = [-1 -1 -1; 1 -1 -1; 1 1 -1; -1 1 -1; -1 -1 1; 1 -1 1; 1 1 1; -1 1 1]/2;
v = v.*s + c;
f = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];
patch(ax, 'Vertices', v, 'Faces', f, 'FaceColor', col, 'EdgeColor', 'none');
end
