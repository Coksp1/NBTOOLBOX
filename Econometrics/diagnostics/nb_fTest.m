function [fTest,fProb] = nb_fTest(residual1,residual2,nCoeff1,nCoeff2)    
% Syntax:
%
% [fTest,fProb] = nb_fTest(residual1,residual2,nCoeff1,nCoeff2)
%
% Description:
%
% Calculates the F-statistics for beta = 0 restrictions.
%
% RSS1  = residual1'*residual1;
% RSS2  = residual2'*residual2;
% fTest = ((RSS1 - RSS2)/(nCoeff2 - nCoeff1))/(RSS2/(T - nCoeff2));
% 
% Input:
% 
% - residual1 : Residuals from the restricted model.
%
% - residual2 : Residuals from the unrestricted model.
% 
% - nCoeff1   : Number of estimated coefficients of the restricted 
%               model. 
%
% - nCoeff2   : Number of estimated coefficients of the unrestricted 
%               model.
%
% Output:
% 
% - fTest : F-statistic
%
% - fProb : F-test statistic p-value.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    residual1 = residual1(:);
    residual2 = residual2(:);
    
    T  = size(residual1,1);
    T2 = size(residual1,1);
    if T ~= T2
        error([mfilename ':: The residuals from the compared models must be of the same size.'])
    end
      
    RSS1  = residual1'*residual1;
    RSS2  = residual2'*residual2;
    fTest = ((RSS1 - RSS2)/(nCoeff2 - nCoeff1))/(RSS2/(T - nCoeff2));
    fProb = nb_fStatPValue(fTest, nCoeff2 - nCoeff1, T - nCoeff2);
    
end
