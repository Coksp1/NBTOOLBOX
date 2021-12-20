function obj = checkModel(obj)
% Syntax:
%
% obj = checkModel(obj)
%
% Description:
%
% Secure that the object is up to date when it comes to the options,
% estOptions and results struct properties.
% 
% Input:
% 
% - obj : An object of class nb_model_group.
% 
% Output:
% 
% - obj : An object of class nb_model_group.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(obj,'nb_model_selection_group')
        options     = obj.options;
        options     = nb_defaultField(options,'maxAR',0);
        options     = nb_defaultField(options,'maxMA',0);
        options     = nb_defaultField(options,'SAR',0);
        options     = nb_defaultField(options,'SMA',0);
        options     = nb_defaultField(options,'algorithm','hr');
        options     = nb_defaultField(options,'stabilityTest',true);
        options     = nb_defaultField(options,'real_time_estim',0); 
        options     = nb_defaultField(options,'scoreHor','');
        obj.options = options;
    end
    
    for ii = 1:length(obj.models)
        obj.models{ii} = checkModel(obj.models{ii});
    end
    
    if isprop(obj,'valid')
        if isempty(obj.valid)
            obj.valid = true(1,length(obj.models));
        end
    end
    
    if ~nb_isempty(obj.forecastOutput)
        obj.forecastOutput.nowcast = 0;
        obj.forecastOutput.missing = [];
    end
    
end
