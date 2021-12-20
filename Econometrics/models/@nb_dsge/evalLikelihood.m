function lik = evalLikelihood(obj)
% Syntax:
%
% lik = evalLikelihood(obj)
%
% Description:
%
% Evaluate the likelihood at the current parameters.
% 
% Input:
% 
% - obj : A scalar nb_dsge object.
% 
% Output:
% 
% - lik : Minus the log likelihood.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    options       = getEstimationOptions(obj);
    [~,estStruct] = nb_dsge.getObjectiveForEstimation(options{1},false);
    lik           = nb_dsge.likelihood(estStruct.init,estStruct);

end
