function [test,pval,res] = mincerZarnowitzTest(obj,precision)
% Syntax:
%
% [test,pval,res] = mincerZarnowitzTest(obj,precision)
%
% Description:
%
% Do the Mincer-Zarnowitz test for bias in the recursive forecast.
% 
% Input:
% 
% - obj       : An object of class nb_model_group. You need to call the 
%               combineForecast method first!
% 
% - precision : The precision of the printed result. As a string. Default
%               is '%8.6f'.
%
% Output:
% 
% - test    : A nb_ts object with the test statistic. As a 
%             nHor x nModel x nVar nb_ts object.
%
% - pval    : A nb_ts object with the p-values of the test. As a 
%             nHor x nModel x nVar nb_ts object.
%
% - res     : A char with the printout of the test.
%
% See also:
% nb_model_generic.combineForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    error([mfilename ':: The Mincer-Zarnowitz test is not yet supported for models with converted frequencies.'])
    
end
