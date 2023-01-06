classdef (Abstract) nb_calculate_only < nb_calculate_generic & nb_model_estimate & nb_model_name
% Description:
%
% An abstract superclass for all classes that has a calculate method but  
% does not inherit the nb_model_generic class. 
%
% Superclasses:
% nb_calculate_generic
%
% Constructor:
%
%   This class is abstract, and has no constructor,
% 
% See also:
% nb_calculate_generic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
   
    properties

        % Adds the posibility to add user data. Can be of any type
        userData        = '';
        
    end

    methods (Hidden=true)
        
        function obj = setProps(obj,s)
            
            fields = fieldnames(s);
            for ii = 1:length(fields)
                try
                    obj.(fields{ii}) = s.(fields{ii});
                catch Err
                    if ~strcmpi(Err.identifier,'MATLAB:class:noSetMethod')
                        rethrow(Err)
                    end
                end
            end
            
        end
        
    end
    
    methods (Hidden=true,Abstract=true)
        
        varargout = getEstimationOptions(varargin)
        tempObj   = setNames(tempObj,inputValue,type)
  
    end

    methods (Static=true,Hidden=true)    
        
        function dispProperties(className)
            props = properties(className);
            props = sort(props);
            for ii = 1:length(props)
                disp(nb_createLinkToClassProperty(className,props{ii}));
            end
            disp(' ');
        end
        
        function dispMethods(className)
            meths = methods(className);
            meths = sort(meths);
            for ii = 1:length(meths)
                disp(nb_createLinkToClassProperty(className,meths{ii}));
            end
            disp(' ');
        end
        
    end
    
end

