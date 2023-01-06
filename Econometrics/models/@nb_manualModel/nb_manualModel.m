classdef nb_manualModel < nb_model_generic
% Description:
%
% A class for estimation and forecasting a model programmed by the user.
%
% Superclasses:
%
% nb_model_generic
%
% Constructor:
%
%   obj = nb_manualModel(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_manualModel object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set, nb_manualModel.template,
% nb_manualModel.help
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    methods
        
        function obj = nb_manualModel(varargin)
        % Constructor

            obj         = obj@nb_model_generic();
            temp        = nb_manualModel.template();
            obj.options = temp;
            obj         = set(obj,varargin{:});
            
        end
        
    end
    
    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = 'MANUAL';
            if ~isempty(obj.options.rollingWindow)
                name = [name ,'_RW' int2str(obj.options.rollingWindow)];
            end
            
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
    end
    
end

