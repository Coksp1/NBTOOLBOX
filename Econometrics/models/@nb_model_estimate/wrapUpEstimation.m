function obj = wrapUpEstimation(obj,res,estOpt)
% Syntax:
%
% obj = wrapUpEstimation(obj,res,estOpt)
%
% Description:
%
% Assign estimation output to object.
% 
% Input:
% 
% - obj    : An object of class nb_model_estimate.
%
% - res    : A struct with the estimation results of the assign object.
%
% - estOpt : A struct with the estimation options of the assign object.
% 
% Output:
% 
% - obj : An object of class nb_model_estimate.
%
% See also:
% nb_model_estimate.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.results    = res;
    obj.estOptions = estOpt;
    if isprop(obj,'solution')
        obj = setSolution(obj,struct());
    end
    
end
