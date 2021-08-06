classdef nb_model_group < nb_model_forecast
% Description:
%
% A class for combining models or model groups for forecast, irfs and so 
% on.
%
% Constructor:
%
%   obj = nb_model_group(models)
% 
%   Input:
%
%   - models : Either a vector of nb_model_generic or nb_model_group 
%              objects or a cell array with a combination of them.
% 
%   Output:
% 
%   - obj    : A nb_model_group object
% 
%   Examples:
% 
% See also:
% nb_model_generic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

   properties
       
       % A cell array of nb_model_generic and nb_model_group objects
       models         = {};
       
   end
   
   properties (SetAccess=protected)
   
       % A logical array of same dimension as models. If an element is
       % false that means that a error occured during estimation or
       % forecasting for the corresponding model/model group.
       valid          = []
       
   end
   
   methods
       
       function obj = nb_model_group(models)
       % Constructor
       
            if nargin < 1
                models = {};
            end
            
            % Create identifier for this object
            obj.identifier = nb_model_name.findIdentifier();
            
            if isa(models,'nb_model_estimate')
                models = nb_obj2cell(models);% convert to cell array
            end
            obj.models = models;
            obj.valid  = true(1,length(models));
           
       end
       
   end
   
   methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = 'MODEL_GROUP';
            name = [name ,'_NM', int2str(length(obj.models))];
            
        end
        
    end
   
   methods (Static=true)
       
       varargout = getActual(varargin);
       varargout = loadModelsFromPath(varargin);
       varargout = unstruct(varargin);
       
   end
   
   methods (Access=private,Static=true)
      
       varargout = adjustForecastGivenNowcast(varargin);
       
   end
    
end
