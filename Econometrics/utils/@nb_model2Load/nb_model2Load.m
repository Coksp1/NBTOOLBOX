classdef (Abstract) nb_model2Load < handle
% Description:
%
% A super class of objects that can be loaded by the
% nb_model_group_vintages class.
%
% Written by Kenneth Sæterhagen Paulsen

    methods (Abstract=true)
        
        % Syntax:
        %
        % model = getModel(obj)
        %
        % Description:
        %
        % Get the name of the model to load.
        % 
        % Input:
        % 
        % - obj   : An object array of class nb_model2Load.
        % 
        % Output:
        % 
        % - model : A char with the model name.
        %
        % Written by Kenneth Sæterhagen Paulsen
        model = getModel(obj) 
        
        % Syntax:
        % 
        % model = loadModel(obj)
        % model = loadModel(obj,withFcst)
        %
        % Description:
        %
        % Load a model as a nb_model_update_vintages
        % 
        % Input:
        % 
        % - obj      : A scalar object of class nb_model2Load.
        %
        % - withFcst : true or false. Default is true. If true the forecast 
        %              are fetched from the database and stored to the
        %              forecastOutput property of the returned model.
        % 
        % Output:
        % 
        % - model    : A scalar nb_model_update_vintages.
        %
        % Written by Kenneth Sæterhagen Paulsen
        model = loadModel(obj,withFcst)
        
        % Syntax:
        %
        % ret = isUpdated(obj)
        %
        % Description:
        %
        % Is the model updated or not?
        % 
        % Input:
        % 
        % - obj : An object array of class nb_model2Load.
        % 
        % Output:
        % 
        % - ret : true or false.
        %
        % Written by Kenneth Sæterhagen Paulsen
        ret = isUpdated(obj)
        
        % Syntax:
        %
        % s = struct(obj)
        %
        % Description:
        %
        % Convert object to a struct.
        %
        % Written by Kenneth Sæterhagen Paulsen
        s = struct(obj)
        
    end
    
    methods (Static=true)
        
        function obj = unstruct(s)
        % Syntax:
        %
        % obj = nb_model2Load.unstruct(s)
        %
        % Description:
        %
        % Convert object from struct.
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            if isa(s,'nb_model2Load')
                % Add support for old cases.
                obj = s;
                return
            end
        
            if ~isstruct(s)
                error([mfilename ':: Load failed. Input must be a struct.'])
            end
            if isfield(s,'class')
                unstructFunc = str2func([s(1).class '.unstruct']);
            else
                error([mfilename ':: Load failed. No field class found.'])
            end
            obj = unstructFunc(s);
            
        end
        
    end

end
