function ret = nb_isModelMarkovSwitching(model)
% Syntax:
%
% ret = nb_isModelMarkovSwitching(model)
%
% Description:
%
% Test if a model is a Markov switching. See nb_model_generic.solution
% for more on the model input.
% 
% Output:
% 
% - ret : true if Markov switching model. 
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if ~isfield(model,'A')
        ret = false;
        return
    end
    ret = iscell(model.A) && ~strcmpi(model.type,'nb');
    
end
