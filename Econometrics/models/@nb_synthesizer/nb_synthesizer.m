classdef nb_synthesizer < nb_calculate_only
% Description:
%
% A class for generating a synthetic series of a variable. 
%
% Constructor:
%
%   obj = nb_synthesizer(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_synthesizer object.
% 
% See also:
% nb_calculate_factors, nb_pca
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    properties (Constant = true)
        
        availableScoreCrit     = 'RMSE, MSE, MAE, EELS, ESLS';
        
        availableScoreCritCell = {'RMSE','MSE','MAE','EELS','ESLS'};
        
    end

    methods

        function obj = nb_synthesizer(t)
        % Constructor
            
            % Set the properties and options of the model
            obj.options = t;

        end
        
    end
    
    methods (Hidden=true)
        
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = upper(obj.options.estim_method);
        end
        
        function tempObj = setNames(tempObj,~,~)
              
        end
        
    end
    
    methods (Static=true)
        
        varargout = setDataOfModels(varargin)
        varargout = template(varargin)
        varargout = help(varargin)
             
    end
    
end
