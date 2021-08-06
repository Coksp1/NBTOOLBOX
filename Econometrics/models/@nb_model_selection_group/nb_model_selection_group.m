classdef nb_model_selection_group < nb_model_group & nb_modelData
% Description:
%
% A class for doing model selection.
%
% Superclasses:
%
% nb_model_group, nb_modelData
%
% Constructor:
%
%   obj = nb_model_selection_group(models)
% 
%   Input:
%
%   - models : A 1 x N vector of nb_model_generic object.
%
%   Output:
% 
%   - obj    : An object of class nb_model_selection_group
% 
%   Examples:
% 
% See also: 
% nb_model_group
%
% Written by Kenneth Sæterhagen Paulsen
   
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

   methods 
       
        function obj = nb_model_selection_group(models, varargin)
            
            if nargin < 1
                models = {};
            end
            obj         = obj@nb_model_group(models);
            obj.options = nb_model_selection_group.template();
            obj         = set(obj, varargin{:});
            
        end
        
   end
   
   methods        
       varargout = modelSelection(varargin);
       varargout = set(varargin);
   end
   
   methods(Hidden=true)
       
       function obj = setOptions(obj,options)
           obj.options = options;
       end
       
   end
   
   methods (Static)     
       varargout = template(varargin)
       varargout = help(varargin)   
       varargout = test(varargin)
   end
   
end
