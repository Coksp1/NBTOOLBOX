classdef nb_harmonizer < nb_model_generic
% Description:
%
% A class for harmonize forecast from other models based on some
% restrictions.
%
% Superclasses:
%
% nb_model_generic
%
% Constructor:
%
%   obj = nb_harmonizer(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_harmonizer object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        
        
    end
    
    methods
        
        function obj = nb_harmonizer(varargin)
        % Constructor

            obj         = obj@nb_model_generic();
            temp        = nb_harmonizer.template();
            obj.options = temp;
            obj         = set(obj,varargin{:});
            
        end
        
    end
    
    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = 'HARMONIZE';
            
        end
        
    end
    
    methods(Access=protected)
       
        function param = getParametersNames(~)
            % Construct the coeff names
            param = struct('name',{{}},'value',[]);
        end
        
    end
    
    methods(Static=true)  
        varargout = template(varargin)
        varargout = help(varargin)
        varargout = solveNormal(varargin)
        varargout = solveRecursive(varargin)
    end
    
end

