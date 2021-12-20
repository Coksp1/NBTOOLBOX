function obj = obsModel2func(obj)
% Syntax:
%
% obj = obsModel2func(obj)
%
% Description:
%
% Create the obsEqFunction to be used to evaluate the derivatives of the
% obs_model block.
% 
% See also:
% nb_dsge.solvNB
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = checkObsModelEqs(obj);
    
    % Now we need to convert the equation into a function handle
    if isfield(obj.parser,'obs_equationsParsed')
        [~,obj.parser.obsEqFunction] = nb_dsge.eqs2funcSub(obj.parser,obj.parser.obs_equationsParsed,2);
        obj.parser                   = rmfield(obj.parser,'obs_equationsParsed');
    end
    
end
