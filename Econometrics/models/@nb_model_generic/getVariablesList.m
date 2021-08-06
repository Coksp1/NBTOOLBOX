function [vars,observables] = getVariablesList(obj,type)
% Syntax:
%
% [vars,observables] = getVariablesList(obj,type)
%
% Description:
%
% Get list of variables given nb_model_generic object thet may analyzed
% 
% Input:
% 
% - obj  : A scalar nb_model_generic object
%
% - type : 'forecast' or 'others'. Defualt is 'forecast'.
% 
% Output:
% 
% - vars        : A cellstr with the variables the model may forecast. 
%                 These are the variables that may be given to the  
%                 'varOfInterest' input to the forecast method of the  
%                 nb_model_generic forecast, when the 'output' input is 
%                 set to 'all'.
%
% - observables : A cellstr with the observables the model may forecast. 
%                 These are the observables that may be given to the  
%                 'observables' input to the forecast method of the  
%                 nb_model_generic forecast, when the 'output' input is 
%                 set to 'all'. Only some specific class of models.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'forecast';
    end
    
    if numel(obj) ~= 1
        error([mfilename ':: This function only handle scalar nb_model_generic objects'])
    end
    
    observables = {};
    switch lower(type)
        
        case 'forecast'
    
            if isa(obj,'nb_fmdyn') || isa(obj,'nb_favar') % Factor model
                observables = obj.observables.name;
                if isa(obj,'nb_favar')
                    observables = [observables,obj.observablesFast.name];
                end
            end
            inputs = struct('reporting',{obj.reporting},'output','all',...
                            'observables',{{}});
            vars   = nb_forecast.getForecastVariables(obj.estOptions,obj.solution,inputs,'all');
            
        otherwise
            
            vars     = {};
            try vars = [vars, obj.dependent.name]; end %#ok<TRYNC>
            try vars = [vars, obj.block_exogenous.name]; end %#ok<TRYNC>
            if isa(obj,'nb_fmdyn') || isa(obj,'nb_favar')
                vars = [vars,obj.estOptions(end).factors];
            end
            
    end

end
