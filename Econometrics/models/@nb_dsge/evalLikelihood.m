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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    options       = getEstimationOptions(obj);
    [~,estStruct] = nb_dsge.getObjectiveForEstimation(options{1},false);
    lik           = nb_dsge.likelihood(estStruct.init,estStruct);

end
