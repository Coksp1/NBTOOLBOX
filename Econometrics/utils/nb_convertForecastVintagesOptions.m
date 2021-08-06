classdef nb_convertForecastVintagesOptions < nb_settableValueClass
% Description:
%
% Stores the options on how to convert the frequncy of a forecasted 
% variable.
%
% Constructor:
%
%   obj = nb_convertForecastVintagesOptions()
%   obj = nb_convertForecastVintagesOptions(varargin)
%
%   Input:
%
%   - varargin : PropertyName, propertyValue pairs. E.g:
%                nb_convertForecastVintagesOptions('method','sum',...)
% 
% See also:
% nb_convert_forecast_vintages
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    properties 
        
       % See help on the 'fill' input to the nb_ts.convert method. 
       fill             = 'nan'; 
        
       % See help on the 'interpolateDate' input to the nb_ts.convert
       % method.
       interpolateDate  = 'end';
       
       % See help on the method input to the nb_ts.convert method.
       method           = '';
       
    end
    
    methods 
       
        function obj = nb_convertForecastVintagesOptions(varargin)
            
            if nargin == 0
                return
            else
                obj = set(obj,varargin);
            end
            
        end
            
        function opt = getOptions(obj)
           props = properties(obj);
           props = setdiff(props,{'method'});
           opt   = cell(1,size(props,1)*2+1);
           for ii = 1:length(props)
               opt{ii*2}   = props{ii};
               opt{ii*2+1} = obj.(props{ii});
           end
           opt{1} = obj.method;
        end
        
        function obj = set.fill(obj,value)
           
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The fill property must be set to a one line char.'])
            end
            choices = {'nan','zeros'};
            if ~any(strcmpi(value,choices))
                error([mfilename ':: The fill property cannot be set to ' value '.'])
            end
            obj.fill = value;
            
        end
        
        function obj = set.interpolateDate(obj,value)
           
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The interpolateDate property must be set to a one line char.'])
            end
            choices = {'start','end'};
            if ~any(strcmpi(value,choices))
                error([mfilename ':: The interpolateDate property cannot be set to ' value '.'])
            end
            obj.interpolateDate = value;
            
        end
        
        function obj = set.method(obj,value)
           
            if ~nb_isOneLineChar(value)
                error([mfilename ':: The method property must be set to a one line char.'])
            end
            obj.method = value;
            
        end
        
        function s = saveobj(obj)
        % Syntax:
        %
        % s = saveobj(obj)
        %
        % Description:
        %
        % Save object to .mat. Called by the save method.
        % 
        % Written by Kenneth S. Paulsen   
        
             s = struct(obj);
             
        end
        
        function s = struct(obj)
        % Syntax:
        %
        % s = struct(obj)
        %
        % Description:
        %
        % Convert object to struct.
        % 
        % Written by Kenneth S. Paulsen      
        
            s     = struct();
            props = properties(obj);
            for ii = 1:length(props)
                s.(props{ii}) = obj.(props{ii});
            end
            
        end
        
    end
    
    methods (Static=true)
        
        function obj = loadobj(s)
        % Syntax:
        %
        % obj = nb_convertForecastVintagesOptions.loadobj(s)
        %
        % Description:
        %
        % Load object from .mat
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            if ~isstruct(s)
                error([mfilename ':: Load failed. Input must be a struct.'])
            end
            obj = nb_convertForecastVintagesOptions.unstruct(s);
            
        end
        
        function obj = unstruct(s)
        % Syntax:
        %
        % obj = nb_convertForecastVintagesOptions.unstruct(s)
        %
        % Description:
        %
        % Convert struct to a object.
        %
        % Written by Kenneth Sæterhagen Paulsen
        
            if isa(s,'nb_convertForecastVintagesOptions')
                obj = s; % backwards compatibility
                return
            end
        
            obj    = nb_convertForecastVintagesOptions();
            fields = fieldnames(s);
            for ii = 1:length(fields)
                if isprop(obj,fields{ii})
                    obj.(fields{ii}) = s.(fields{ii});
                end
            end
            
        end
        
    end
    
end
