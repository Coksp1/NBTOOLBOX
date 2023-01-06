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
% - obj    : An object of class nb_model_convert.
%
% - res    : A struct with the estimation results of the assign object.
%
% - estOpt : A struct with the estimation options of the assign object.
% 
% Output:
% 
% - obj : An object of class nb_model_convert.
%
% See also:
% nb_model_estimate.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    model = obj.model;
    model = setResult(model,res);
    model = setEstOptions(model,estOpt);
    obj   = setModel(obj,model);
                
end
