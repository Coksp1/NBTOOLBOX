function obj = createEqFunction(obj,eqId)
% Syntax:
%
% obj = createEqFunction(obj)
% obj = createEqFunction(obj,eqId)
%
% Description:
%
% Create the eqFunction to be used to evaluate the derivatives.
% 
% See also:
% nb_dsge.blockDecompose, nb_dsge.addEquation, nb_dsge.solveSteadyState
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        eqId = 'equationsParsed';
    end
    
    if ~strcmpi(eqId,'equationsParsed')
        obj.parser = nb_dsge.eqs2func(obj.parser,eqId);
    else
        
        if isfield(obj.parser,'equationsParsed')
            % Create function handle to user for evaluating the steady-state 
            % and to calculate the derivatives
            obj.parser = nb_dsge.eqs2func(obj.parser);
            obj.parser = rmfield(obj.parser,'equationsParsed');
            obj.parser = nb_rmfield(obj.parser,'derivativeFunc'); % Trigger re-calculation of symbolic derivatives
        end
        
    end
    
end
