function [betaDraws,factorDraws] = bootstrapModel(options,res,iter)
% Syntax:
%
% [betaDraws,factorDraws] = 
%    nb_dfmemlEstimator.bootstrapModel(options,res,iter)
%
% Description:
%
% Not possible to bootstrap this model.
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    error([mfilename ':: It is not possible to bootstrap a nb_fmdyn model estimated ',...
                     'with ''estim_method'' set to ''dfmeml''.'])
    
end
