function weights = nb_restrictedWeights(scores,limits,selectors)
% Syntax:
%
% weights = nb_restrictedWeights(scores,limits,selectors)
%
% Description:
%
% Convert scores into weights using the formula:
%
% weight(h,v,c,i) = score(h,v,c,i)/sum_i(score(h,v,c,i))
%
% but were the number of kept models are given some criteria and dependent
% on the number of models that are being weighted.
% 
% Input:
% 
% - scores    : A nHor x nVar x nContexts x nModel double.
% 
% - limits    : A 1 x N - 1 double with the limits of the N selectors. 
%               Default is [10,100]. The limits apply to the number of
%               models. By the default we use selector 1, if number of
%               models are less then 10. Selector 2 if models are less 
%               then 100, and selector 3 if greater or equal to 100.
%
% - selectors : A 1 x N cell array with the selectors for each interval.
%               The selectors must take one input, and return the number 
%               of selected numbers out of the number provided models.
%               Default is {@(x)max(3,round(x*0.5)),
%               @(x)max(5,round(x*0.2)),@(x)20}
%
% Output:
% 
% - weights : A nHor x nVar x nContexts x nModel double.
%
% See also:
% nb_model_group_vintages.constructWeights, 
% nb_model_group_vintages.combineForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        selectors = {@(x)max(3,round(x*0.5)),@(x)max(5,round(x*0.2)),@(x)20};
        if nargin < 2
            limits = [10,100];
        end
    end
    
    if ~(isrow(limits) && isnumeric(limits))
        error('The limits input must be a 1 x N - 1 double.')
    end
    if ~(isrow(selectors) && iscell(selectors))
        error('The selectors input must be a 1 x N cell array.')
    end
    if size(limits,2) ~= size(selectors,2) - 1
        error(['The limits input (' int2str(size(limits,2)) ') must have one element ',...
               'less then the selectors input (' int2str(size(selectors,2)) ')'])
    end
    limits  = [limits, inf];
    nModels = size(scores,4);
    crit    = find(nModels < limits,1);
    try
        Q = selectors{crit}(nModels);
    catch Err
        nb_error(['Error calling the selector function number ' num2str(crit) '; ' func2str(selectors{crit})],Err);
    end
    weights = selectModelsAndWeight(scores,Q);
    
end

%==========================================================================
function weights = selectModelsAndWeight(scores,Q)

    [~,ind]   = sort(scores,4,'descend');
    [H,V,C,M] = size(scores);
    N         = min(Q, M);
    for h = 1:H
        for v = 1:V
            for c = 1:C
                i               = ind(h,v,c,N+1:end);
                scores(h,v,c,i) = 0;
            end
        end
    end
    sumScores = sum(scores,4,'omitnan');
    weights   = bsxfun(@rdivide,scores,sumScores);
        
end
