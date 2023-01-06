function optimizer = dynareOptimizer(mode_compute)
% Syntax:
%
% optimizer = nb_dsge.dynareOptimizer(mode_compute)
%
% Description:
%
% Get name of dynare optimizer.
% 
% Input:
% 
% - mode_compute : The mode_compute input to Dynare estimation.
% 
% Output:
% 
% - optimizer    : The name of the optimizer.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    switch mode_compute
        case 1
            optimizer = 'fmincon';
        case 3
            optimizer = 'fminunc';
        case 4
            optimizer = 'csminwel1';
        case 5
            optimizer = 'newrat';
        case 6
            optimizer = 'gmhmaxlik';
        case 7
            optimizer = 'fminsearch';
        case 101
            optimizer = 'solvopt';
        case 102
            optimizer = 'sa';        
        otherwise  
            optimizer = 'User defined';
    end

end
