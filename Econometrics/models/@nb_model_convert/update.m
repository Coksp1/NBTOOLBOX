function [obj,valid] = update(obj,type,warningOn,inGUI,groupIndex,varargin)
% Syntax:
%
% obj         = update(obj,type)
% [obj,valid] = update(obj,type,warningOn,inGUI,groupIndex,varargin)
%
% Description:
%
% Update data of the object, and optionally re-estimate, re-solve, 
% forecast the models given the updated data and convert the forecast.
% 
% Input:
% 
% - obj         : A vector of objects of class nb_model_group
% 
% - type        : > ''         : Only update data. Default
%                 > 'estimate' : Update data and estimate.
%                 > 'solve'    : Update data, estimate and solve
%                 > 'forecast' : Update data, estimate, solve and forecast.
%
% - warningOn   : 'on' or 'off'. If 'on' only warnings are given while 
%                 the data source is updated, else an error will be given.
%                 Default is 'on'. Set it to 'off', if the 'write' option
%                 is used.
%
% - inGUI       : 'on' or 'off'. Indicate if the update command is called 
%                 in the GUI or not. Default is 'off'.
% 
% - groupIndex  : A 1 x nLevel double with the group level.
%
% Optional input:
%
% - 'write'     : Give this string as one of the optional inputs to write
%                 an error file if estimation or forecasting failes. The
%                 models that failes will then be removed when calling
%                 methods as compareForecast and aggregateForecast etc.
%                 See the valid property.
%
% Output:
% 
% - obj   : A vector of objects of class nb_model_convert.
%
% - valid : A logical with size 1 x nObj. true at location ii if 
%           updating of model group ii succeded, otherwise false. If 
%           'write' is not used an error will be thrown instead, so in 
%           this case this output will be true for all models.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        groupIndex = [];
        if nargin < 4
            inGUI = 'off';
            if nargin < 3
                warningOn = 'on';
                if nargin < 2
                    type = '';
                end
            end
        end
    end
    [obj.model,valid] = update(obj.model,type,warningOn,inGUI,groupIndex,varargin);
    
end
