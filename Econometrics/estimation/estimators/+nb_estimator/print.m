function res = print(results,options,precision)
% Syntax:
%
% res = nb_estimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from for example the 
%               nb_olsEstimator.estimate function.
%
% - options   : A struct with the estimation options from for example the  
%               nb_olsEstimator.estimate function.
%
% - precision : The precision of the printed result.
% 
% Output:
% 
% - results : A char with the estimation results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin<3
        precision = '';
    end
    func = str2func([options(end).estimator '.print']);
    res  = func(results,options(end),precision);
         
end

