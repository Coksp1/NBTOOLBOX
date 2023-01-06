function dummyPriorOptions = getDummyPriorOptions(nLags,prior,constant,time_trend)
% Syntax:
%
% dummyPriorOptions = nb_bVarEstimator.getDummyPriorOptions(nLags,...
%       prior,constant,time_trend)
%
% Description:
%
% Return a structure that contains all options used by the
% nb_bVarEstimator.applyDummyPrior function.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isfield(prior,'LR')
        prior.LR = false;
    end
    if ~isfield(prior,'SC')
        prior.SC = false;
    end
    if ~isfield(prior,'DIO')
        prior.DIO = false;
    end
    if ~isfield(prior,'SVD')
        prior.SVD = false;
    end
    if prior.LR || prior.SC || prior.DIO || prior.SVD
        dummyPriorOptions = struct(...
            'prior',prior,...
            'constant',constant,...
            'time_trend',time_trend,...
            'nLags',nLags-1); % For non-missing this is the case!
    else
        dummyPriorOptions = [];
    end

end

