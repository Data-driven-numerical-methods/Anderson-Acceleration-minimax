function [x,iter,res_hist,rest_hist] = NLSCDM(g, solution, x, mMax,itmax,atol, print)
% This performs fixed-point iteration with or without Anderson
% acceleration for a given fixed-point map g and initial
% approximate solution x.
%
% Required inputs:
% g = fixed-point map (function handle); form gval = g(x).
% x = initial approximate solution (column vector).




tol = atol;
% Initialize the storage arrays.
res_hist = []; % Storage of residual history.
rest_hist =[];
DG = []; % Storage of g-value differences.
% Initialize printing.
if mMax == 0
    fprintf('\n No acceleration.');
elseif mMax > 0
    fprintf('\n Anderson acceleration, mMax = %d \n',mMax);
else
    error('AndAcc.m: mMax must be non-negative.');
end
fprintf('\n iter res_norm \n');
% Initialize the number of stored residuals.
mAA = 0;
gval = g(x);
fval = gval - x;
f_old = fval;
g_old = gval;
x = gval;
tic
Dat.DX = [];  Dat.DF = []; Dat.nv = mMax; Dat.beta = 1.0; 
% Top of the iteration loop.
for iter = 1:itmax+1
    
% Apply g and compute the current residual norm.
    if mod(iter, print) ==0
        res_norm = (norm(gval - solution));
        fprintf('%d %e \n', iter, res_norm);
        res_hist = [res_hist;[iter,res_norm]];
        rest_hist = [rest_hist;[toc,res_norm]];
        if res_norm <= tol || isnan(res_norm)
            fprintf('Terminate with residual norm = %e \n\n', res_norm);
            break;
        end
    end
    gval = g(x);
    [x, Dat] = nlgmr(x, Dat, g);
    if mod(iter,10) == 0
       mAA = 0;
       Dat.DX = []; Dat.DF = [];
    end
end
% Bottom of the iteration loop.
if res_norm > tol && iter == itmax
    fprintf('\n Terminate after itmax = %d iterations. \n', itmax);
    fprintf(' Residual norm = %e \n\n', res_norm);
end