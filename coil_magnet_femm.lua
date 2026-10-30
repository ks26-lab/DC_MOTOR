-- ============================================================================
--  coil_magnet_femm.lua      FEMM 4.2 magnetostatic model of the coil / two-magnet rig
--
--  MODEL: 2D planar cross-section of the 3D rig, cut by the plane perpendicular to the
--  wire (the wire axis = out-of-page direction, passing through the origin).
--      FEMM x  =  rig y   (direction across the gap between the magnets)
--      FEMM y  =  rig z   (vertical, origin placed on the wire / coil centre)
--  What appears in the cut:
--      * two rectangular NdFeB blocks, one each side of the coil, both magnetised along +x
--        (left block N face toward coil, right block S face toward coil)
--      * the coil ring: its two sides cut by the plane = two small conductor cross-sections
--        carrying +N*I and -N*I (out of / into the page), tilted by angle theta about the origin
--  Not visible in this plane: posts, eyelets, terminal boxes, wire, base plate (non-magnetic).
--
--  OUTPUT:  femm_results.csv   theta[deg], torque [N*m], Fy_right, Fy_left, B_center [T],
--                              analytic dipole torque [N*m]
--           gap_scan.csv       B across the gap at the wire height (theta = 0)
--           B_theta_0.png      flux density plot (theta = 0)
--  Run:  FEMM -> File -> Open Lua Script... -> select this file.
--  Planar "depth" is set to pi*r_mean/2, so the planar torque approximates the torque on the
--  full ring in a uniform field (tau = N*I*pi*r^2*B). The 2D magnets are effectively infinitely
--  long, so the field is somewhat larger than in the real 3D case.
-- ============================================================================

-- ---------------- Parameters (SI, metres) ----------------
Ri   = 0.032        -- coil inner radius
Ro   = 0.045        -- coil outer radius
hc   = 0.004        -- coil winding thickness (vertical)
Nt   = 12           -- number of turns (about 3 m of 26 SWG wire)
I0   = 2.0          -- coil current [A] (adapter limit)
rm   = (Ri+Ro)/2
depth = pi*rm/2     -- equivalent planar depth

magT = 0.006        -- N35 magnet thickness (along the gap direction, magnetised direction)
magH = 0.012        -- N35 magnet height (block is 20 x 12 x 6 mm)
magY = 0.053        -- magnet centre distance from the origin
Hc   = 909000       -- coercivity [A/m]  (N35, Br ~ 1.2 T, mu_r = 1.05)

Rbound = 0.30       -- radius of the solution domain

showconsole()
clearconsole()

-- ---------------- Helpers ----------------
function rotx(x, y, t) return x*cos(t) - y*sin(t) end
function roty(x, y, t) return x*sin(t) + y*cos(t) end

-- Draw a rectangle [xa,xb] x [ya,yb] (local coords) rotated by t about the origin
function rot_rect(xa, xb, ya, yb, t)
  local px = {rotx(xa,ya,t), rotx(xb,ya,t), rotx(xb,yb,t), rotx(xa,yb,t)}
  local py = {roty(xa,ya,t), roty(xb,ya,t), roty(xb,yb,t), roty(xa,yb,t)}
  for i = 1, 4 do mi_addnode(px[i], py[i]) end
  for i = 1, 4 do
    local j = i + 1
    if j > 4 then j = 1 end
    mi_addsegment(px[i], py[i], px[j], py[j])
  end
end

-- ---------------- One magnetostatic solve ----------------
function run_case(thdeg, I, savepics)
  local t = thdeg*pi/180

  newdocument(0)
  mi_probdef(0, "meters", "planar", 1e-8, depth, 30)

  -- materials
  mi_addmaterial("Air",   1,    1,    0,  0, 0, 0, 0, 1, 0, 0, 0)
  mi_addmaterial("NdFeB", 1.05, 1.05, Hc, 0, 0, 0, 0, 1, 0, 0, 0)
  mi_addmaterial("Coil",  1,    1,    0,  0, 0, 0, 0, 1, 0, 0, 0)
  mi_addcircprop("coil", I, 1)                 -- series circuit

  -- magnets (rectangles)
  mi_drawrectangle(-magY-magT/2, -magH/2, -magY+magT/2, magH/2)   -- left
  mi_drawrectangle( magY-magT/2, -magH/2,  magY+magT/2, magH/2)   -- right

  -- coil cross-sections, tilted by t
  rot_rect( Ri,  Ro, -hc/2, hc/2, t)           -- right side
  rot_rect(-Ro, -Ri, -hc/2, hc/2, t)           -- left side

  -- outer boundary
  mi_makeABC(7, Rbound, 0, 0, 0)

  -- block labels
  mi_addblocklabel(0, Rbound*0.5)              -- air
  mi_selectlabel(0, Rbound*0.5)
  mi_setblockprop("Air", 1, 0, "<None>", 0, 0, 0)
  mi_clearselected()

  mi_addblocklabel(-magY, 0)                   -- left magnet, magnetised along +x
  mi_selectlabel(-magY, 0)
  mi_setblockprop("NdFeB", 1, 0, "<None>", 0, 3, 0)
  mi_clearselected()

  mi_addblocklabel(magY, 0)                    -- right magnet, magnetised along +x
  mi_selectlabel(magY, 0)
  mi_setblockprop("NdFeB", 1, 0, "<None>", 0, 3, 0)
  mi_clearselected()

  local xr = rotx( (Ri+Ro)/2, 0, t)
  local yr = roty( (Ri+Ro)/2, 0, t)
  local xl = rotx(-(Ri+Ro)/2, 0, t)
  local yl = roty(-(Ri+Ro)/2, 0, t)

  mi_addblocklabel(xr, yr)                     -- right coil side, +N turns
  mi_selectlabel(xr, yr)
  mi_setblockprop("Coil", 0, 0.0008, "coil", 0, 1,  Nt)
  mi_clearselected()

  mi_addblocklabel(xl, yl)                     -- left coil side, -N turns
  mi_selectlabel(xl, yl)
  mi_setblockprop("Coil", 0, 0.0008, "coil", 0, 2, -Nt)
  mi_clearselected()

  -- solve
  mi_saveas("coil_magnets.fem")
  mi_analyze(1)
  mi_loadsolution()

  -- results: Lorentz torque about the origin (wire axis) and y-forces
  mo_groupselectblock(1)
  local tq1 = mo_blockintegral(16)
  local fy1 = mo_blockintegral(13)
  mo_clearblock()
  mo_groupselectblock(2)
  local tq2 = mo_blockintegral(16)
  local fy2 = mo_blockintegral(13)
  mo_clearblock()
  local tq = tq1 + tq2

  local A, B1, B2 = mo_getpointvalues(0, 0)    -- field at the coil centre (B1 = across the gap)

  if savepics == 1 then
    mo_showdensityplot(1, 0, 0.08, 0, "bmag")
    mo_zoom(-0.13, -0.09, 0.13, 0.09)
    mo_savebitmap("B_theta_0.png")

    -- field scan across the gap at the wire height
    local f = openfile("gap_scan.csv", "w")
    write(f, "x_mm,Bx_T,By_T\n")
    local n = 120
    local xa = -(magY - magT/2) + 0.001
    local xb =  (magY - magT/2) - 0.001
    for i = 0, n do
      local x = xa + (xb - xa)*i/n
      local a, b1, b2 = mo_getpointvalues(x, 0)
      write(f, x*1000, ",", b1, ",", b2, "\n")
    end
    closefile(f)
  end

  mo_close()
  mi_close()
  return tq, fy1, fy2, B1
end

-- ---------------- Angle sweep ----------------
fout = openfile("femm_results.csv", "w")
write(fout, "theta_deg,torque_Nm,Fy_right_N,Fy_left_N,Bgap_center_T,torque_analytic_Nm\n")

area = pi*rm*rm
for k = -6, 6 do
  th = k*5                                           -- -30 ... +30 deg
  show = 0
  if th == 0 then show = 1 end
  tq, fyR, fyL, Bc = run_case(th, I0, show)
  tq_an = Nt*I0*area*Bc*cos(th*pi/180)               -- N*I*A*B*cos(theta) (magnitude)
  write(fout, th, ",", tq, ",", fyR, ",", fyL, ",", Bc, ",", tq_an, "\n")
  print("theta=", th, " deg   torque=", tq, " N*m   B_gap=", Bc, " T   analytic=", tq_an)
end
closefile(fout)

print("Done. Results written to femm_results.csv and gap_scan.csv")
