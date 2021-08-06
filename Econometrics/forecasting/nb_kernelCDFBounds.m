function out = nb_kernelCDFBounds(type)
% Syntax:
%
% out = nb_kernelCDFBounds(type)
%
% Description:
%
% See output.
% 
% Input:
% 
% - type : 1: Lower. 0: Upper.
% 
% Output:
% 
% - out  : Upper or lower bound on CDF estimation by kernel methods.
%
% See also:
% nb_evaluateDensityForecast, nb_simulateFromDensity
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if type 
        out = 0.975;
    else
        out = 1.025; 
    end

end
