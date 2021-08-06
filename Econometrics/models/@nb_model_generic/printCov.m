function printed = printCov(obj)
% Syntax:
%
% printed = printCov(obj)
%
% Description:
%
% Get the estimated covariance matrix results printed to a char array.
%
% Caution: Some estimators may not support this option.
% 
% Input:
% 
% - obj : A vector of nb_model_generic objects.
% 
% Output:
% 
% - printed : A char array with the estimation results.
%
% See also:
% nb_model_estimate.print
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    printed = '';
    obj     = obj(:);
    nobj    = numel(obj);
    if nobj == 0
        error('Cannot print a empty vector of nb_model_generic objects.')
    else
       
        for ii = 1:nobj
            
            res = obj(ii).results;
            opt = obj(ii).estOptions;
            if nb_isempty(res) || ~isfield(opt(end),'estimator')
                printed = char(printed,'');
                printed = char(printed,['No estimated covariance matrix found for model ' int2str(ii)]);
                printed = char(printed,'');
            else
                printed = char(printed,'');
                printed = char(printed,['Model: ' int2str(ii)]);
                printed = char(printed,nb_estimator.printCov(res,opt));
                printed = char(printed,'');
            end
            
        end
        
    end

end
