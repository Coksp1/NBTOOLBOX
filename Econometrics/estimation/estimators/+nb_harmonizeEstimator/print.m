function res = print(~,~,~)
% Syntax:
%
% res = nb_harmonizeEstimator.print(results,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_harmonizeEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_harmonizeEstimator.estimate function.
%
% - precision : The precision of the printed result.
% 
% Output:
% 
% - res       : A char with the estimation results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    res = '';
    res = char(res,'No estimation results to print for a harmonizer model');
    res = char(res,'');
         
end
