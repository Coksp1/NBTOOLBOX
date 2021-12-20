function [loss,names,table] = getLoss(obj)
% Syntax:
%
% loss               = getLoss(obj)
% [loss,names,table] = getLoss(obj)
%
% Description:
%
% Get calculated loss from model. See nb_dsge.calculateLoss or 
% nb_dsge.optimalSimpleRules for how to do this.
% 
% Input:
% 
% - obj  : A N x M matrix of nb_dsge objects.
% 
% Output:
% 
% - loss  : A N x M double with the losses of the different models.
%
% - names : A N x M cellstr with the names of the models.
%
% - table : A 2 x N*M cell with a table of the losses.
%
% See also:
% nb_dsge.calculateLoss, nb_dsge.optimalSimpleRules
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        loss = nb_callMethod(obj,@getLoss,@nan);
    else
        if isfield(obj.results,'loss')
            loss = obj.results.loss;
        else
            loss = nan;
        end
    end
    if nargout > 1
        names = getModelNames(obj);
    end
    if nargout > 2
        table = [nb_rowVector(names);num2cell(nb_rowVector(loss))];
    end
    
end
