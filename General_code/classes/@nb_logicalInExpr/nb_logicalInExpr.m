classdef nb_logicalInExpr < nb_objectInExpr
% Description:
%
% A class representing a logical array that can be used in nb_eval to get 
% the resulting logical array from an expression.
%    
% Constructor:      
%
%   obj = nb_logicalInExpr(data)
% 
%   Input:
% 
%   - data : Logical array.
%
%   Output:
% 
%   - obj  : An object of class nb_logicalInExpr.
% 
%   Examples:
% 
%   obj = nb_logicalInExpr(true);
% 
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
 
    properties
        
        % The date the object represents.
        data = [];
        
        % The type of logical operator to use. Default is '|' (or).
        type = '|';
        
    end
    
    methods
        
        function obj = nb_logicalInExpr(data,type)      
            
            if nargin == 0
               return 
            end
            
            if ~islogical(data) 
                error([mfilename ':: the data input must be a logical array.'])
            end

            % Assign properties
            obj.data = data;
            
            if nargin == 2
                if ~strcmp(type,{'|','&'})
                    error('Type must be set to ''|'' or ''&''.')
                end
                obj.type = type;
            end
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
             
        function obj = compare(obj,aObj)
            if isempty(aObj.data)
                return
            elseif isempty(obj.data)
                obj = aObj;
                return 
            end
            if ~nb_sizeEqual(obj.data,size(aObj.data))
                error('The logical array does not match in size')
            end
            if strcmp(obj.type,'&')
                obj.data = obj.data & aObj.data;
            else
                obj.data = obj.data | aObj.data;
            end
        end
        function obj = compareMax(obj,aObj)
            if isempty(aObj.data)
                return
            elseif isempty(obj.data)
                obj = aObj;
                return 
            end
            if ~nb_sizeEqual(obj.data,size(aObj.data))
                error('The logical array does not match in size')
            end
            if strcmp(obj.type,'&')
                obj.data = obj.data & aObj.data;
            else
                obj.data = obj.data | aObj.data;
            end
        end
        function obj = emptyObject(obj)
            obj.data = [];
        end
        
    end
    
    %======================================================================
    % Hidden methods
    %======================================================================
    methods (Access=public,Hidden=true)
       
    end
    
    %======================================================================
    % Static methods
    %======================================================================
    methods (Static=true)
 
    end
    
end
