classdef nb_manualDataSource < nb_connector
% Description:
%
% Assign a set of function handles to import real-time data for use
% in estimation of a model with the nb_model_vintages class.
%
% Superclasses:
%
% nb_connector
%
% Constructor:
%
%   obj = nb_manualDataSource(varargin)
% 
%   Input:
%
%   - varargin : A set of function_handle objets used to load the real-time
%                data. Each function handle should not take any inputs, and
%                should have at least one output. This output must be
%                a nb_ts object with with more pages, in this case each 
%                page is taken to be the given context of a set of 
%                variables. Context means the observation of each variable
%                a given publication date.
%
%                PS: It is important that each page get assign it context
%                    tag one the format 'yyyymmdd'. See the dataNames
%                    property.
% 
%   Output:
% 
%   - obj : An object of class nb_manualDataSource.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    properties
        
        % The function handles called to fetch the data.
        funcs       = [];
        
    end
    
    methods
        
        function obj = nb_manualDataSource(varargin)
            obj.funcs = varargin;
        end
        
        function ret = hasConditionalInfo(~)
            ret = -1; % Need to be determined based on fetched data 
        end
        
        function value = getLevel(~)
            value = -51; % Level is always -51 in this case, as the datasources is external
        end

        function s = struct(obj)
        
            s = struct('class','nb_manualDataSource','funcs',{obj.funcs});
            
        end
        
    end
    
    methods (Static=true)
        
        function obj = unstruct(s)
        % Syntax:
        %
        % obj = nb_manualDataSource.unstruct(s)
        %
        % Description:
        %
        % Convert struct to a object.
        %
        % Written by Kenneth Sæterhagen Paulsen
        
            if ~isempty(s.funcs)
                if ischar(s.funcs{1})
                    for ii = 1:length(s.funcs)
                        s.funcs{ii} = str2func(s.funcs{ii});
                    end
                end
            end
            obj = nb_manualDataSource(s.funcs{:});
            
        end
        
    end
    
end

