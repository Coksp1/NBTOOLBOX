function res = print(~,~,~)
% Syntax:
%
% res = nb_hpEstimator.print(results,options,precision)
%
% Description:
%
% Get the estimation results as a char.
% 
% Input:
% 
% - results   : A struct with the estimation results from the 
%               nb_hpEstimator.estimate function.
%
% - options   : A struct with the estimation options from the 
%               nb_hpEstimator.estimate function.
%
% - precision : The precision of the printed result.
% 
% Output:
% 
% - results : A char with the estimation results.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

%     if nargin<3
%         precision = '';
%     end
%     
%     precision = nb_estimator.interpretPrecision(precision);
    res       = 'HP-filter provide no estimated coefficients';
         
end
