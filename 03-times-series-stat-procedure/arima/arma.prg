' ARMA
%path = @runpath
cd %path 

wfopen "arma_data"

' Q1
graph graph01_cpi.line cpi
graph01_cpi.setupdate(auto)

' Q2
freeze(table01_correlogram) cpi.correl(36)

' Q3
equation eq01_cpi.ls cpi c ar(1)
freeze(graph02_inverse_roots_ar1) eq01_cpi.arma
freeze(table02_inverse_roots_ar1) eq01_cpi.arma(t)
freeze(graph03_residuals) eq01_cpi.resids(g)
freeze(table03_correlogram_eq) eq01_cpi.correl(36)

' Q4
series p = @pcy(cpi)
graph graph04_p.line p

' Q5
smpl 2000 @last
freeze(table04_correlogram_p) p.correl(36)
equation eq02_p_ar1.ls p c ar(1)
freeze(table05_correlogram_p_ar1) eq02_p_ar1.correl(36)
equation eq03_p_ar2.ls p c ar(1 to 2)
freeze(table06_correlogram_p_ar2) eq03_p_ar2.correl(36)
freeze(graph05_inverse_roots_p_ar2) eq03_p_ar2.arma

' Q6
smpl 2000 2008
equation eq04_p_ar2.ls p c ar(1 to 2) ma(12)
freeze(graph06_pf) eq04_p_ar2.forecast(e, g, forcsmpl=2009 2010) pf

smpl 2000 2010
graph graph07_p_pf.line pf p


