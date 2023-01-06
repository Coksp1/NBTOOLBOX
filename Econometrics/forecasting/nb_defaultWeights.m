function weights = nb_defaultWeights(scores,varargin)
% Syntax:
%
% weights = nb_defaultWeights(scores,varargin)
%
% Description:
%
% Convert scores into weights using the formula:
%
% weight(h,v,c,i) = score(h,v,c,i)/sum_i(score(h,v,c,i))
% 
% where h is the horizon, v is the variable, c is the context and i is the
% model.
%
% Input:
% 
% - scores  : A nHor x nVar x nContexts x nModel double.
% 
% Optional input:
%
% - 'num'    : Only keep X number of models. Must be a scalar integer > 0.
%              If this number is larger than the number of models, all
%              models are selected. The rest of the model is weights as 
%              described.
%
% - 'perc'   : Only keep the X% best models. Must be a scalar double 
%              between 1 and 100. Caution: Will use the ceil operator, to 
%              ensure that the number of selected models are strictly 
%              positive and an integer. The rest of the model is weights 
%              as described. Must be a scalar integer > 0. 
%
% - 'remove' : Remove X number of models. Must be a scalar integer > 0.
%              If this number is larger than the number of models, one
%              model is selected.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    default = {'num',    [],   @(x)nb_isScalarInteger(x,0);...
               'perc',   [],   @(x)nb_isScalarNumber(x,0,100);...   
               'remove', [],   @(x)nb_isScalarNumber(x,0);...
               }; 
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
       
    if ~isempty(inputs.perc)
        [~,ind]   = sort(scores,4,'descend');
        [H,V,C,M] = size(scores);
        N         = ceil((M*(inputs.perc/100)));
        for h = 1:H
            for v = 1:V
                for c = 1:C
                    i               = ind(h,v,c,N+1:end);
                    scores(h,v,c,i) = 0;
                end
            end
        end
        sumScores = nansum(scores,4);
        weights   = bsxfun(@rdivide,scores,sumScores);
    elseif ~isempty(inputs.num)
        [~,ind]   = sort(scores,4,'descend');
        [H,V,C,M] = size(scores);
        N         = min(inputs.num, M);
        for h = 1:H
            for v = 1:V
                for c = 1:C
                    i               = ind(h,v,c,N+1:end);
                    scores(h,v,c,i) = 0;
                end
            end
        end
        sumScores = nansum(scores,4);
        weights   = bsxfun(@rdivide,scores,sumScores);
    elseif ~isempty(inputs.remove)
        [~,ind]   = sort(scores,4,'descend');
        [H,V,C,M] = size(scores);
        N         = max(M - inputs.remove, 1);
        for h = 1:H
            for v = 1:V
                for c = 1:C
                    i               = ind(h,v,c,N+1:end);
                    scores(h,v,c,i) = 0;
                end
            end
        end
        sumScores = nansum(scores,4);
        weights   = bsxfun(@rdivide,scores,sumScores);
    else
        sumScores = nansum(scores,4);
        weights   = bsxfun(@rdivide,scores,sumScores);
    end
end
