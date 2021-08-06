classdef (Abstract) nb_model_options
% Description:
%
% An abstract superclass for all model objects that has a options property.
%
% See also:
% nb_model_estimate, nb_modelData
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties

        % A struct storing all the options to set for the model object
        % of interest. Use the static <className>.help method to get
        % help on each field of the options structure.
        options         = struct();
         
    end
    
    properties (Hidden=true)
        
        % We normally prevent users from setting the data option, but
        % we need to do it in some methods, so we make it an property here.
        preventSettingData = true; 
        
    end
    
    methods
       
        function obj = set.options(obj,value)
            
            if isa(obj,'nb_model_update_vintages')
                obj.options = value;
                return
            end
           
            if isfield(obj.options,'data') && ~isstruct(value.data) && obj.preventSettingData %#ok<MCSUP>
            
                current = obj.options.data;
                new     = value.data;

                try
                    test1 = any(size(current.data) ~= size(new.data));
                catch
                    error([mfilename ':: You cannot set the data option using obj.options.data = value syntax! Use ',...
                                     'obj = set(obj,''data'',value) instead.'])
                end
                if test1
                    error([mfilename ':: You cannot set the data option using obj.options.data = value syntax! Use ',...
                                     'obj = set(obj,''data'',value) instead.'])
                elseif any(current.data(:) - new.data(:) > eps^0.3)
                    error([mfilename ':: You cannot set the data option using obj.options.data = value syntax! Use ',...
                                     'obj = set(obj,''data'',value) instead.'])
                end
                
            end
            
            obj.options = value;
            
        end
        
    end

end
