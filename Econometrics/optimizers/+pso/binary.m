function [xOpt,fval,exitflag,output,population,scores] = binary(fitnessfcn,nvars,options)
% Syntax:
%
% psobinary(fitnessfcn,nvars)
% psobinary(fitnessfcn,nvars,options)
%
% Description:
%
% Particle swarm optimization for binary genomes.
%
% This function will optimize fitness functions where the variables are
% row vectors of size 1xnvars consisting of only 0s and 1s.
%
% PSO.BINARY is provided as a wrapper for PSO.DO, to avoid any confusion. 
% This is because the binary optimization scheme is not designed to take 
% any constraints. PSO.BINARY does not allow the passing of constraints. It
% takes a given optimization problem with binary variables, and
% automatically sets the options structure so that 'PopulationType'
% is 'bitstring'.
%
% This has exactly the same effect as setting the appropriate options
% manually, except that it is not possible to unintentionally define
% constraints, which would be ignored by the binary variable optimizer
% anyway.
%
% Problems with hybrid variables (double-precision and bit-string
% combined) cannot be solved yet.
%
% The output variables for PSO.BINARY is the same as for PSO.DO.
%
% See also:
% nb_pso, pso.do, pso.optimset
%
% Written by S. Samuel Chen. Version 1.31.2.
% Available from http://www.mathworks.com/matlabcentral/fileexchange/25986
% Distributed under BSD license. First published in 2009.
%
% Edited by Kenneth S. Paulsen
% - Made it into a function of the pso package. 10/2018

% Copyright (c) 2009-2016, S. Samuel Chen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3 % Set default options
        options = struct ;
    end % if ~exist
    options = pso.optimset(options,'PopulationType','bitstring') ;

    [xOpt,fval,exitflag,output,population,scores] = ...
        pso.do(fitnessfcn,nvars,[],[],[],[],[],[],[],options) ;
    
end
