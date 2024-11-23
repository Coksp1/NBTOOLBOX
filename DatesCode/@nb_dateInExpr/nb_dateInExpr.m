classdef nb_dateInExpr < nb_objectInExpr
% Description:
%
% A class representing a date that can be used in nb_eval to get the
% end dates of time-series used in an expression.
%    
% Constructor:      
%
%   obj = nb_dateInExpr(date)
% 
%   Input:
% 
%   - date : An object of class nb_date or a one line char that can be 
%            converted to a nb_date object using nb_date.date2freq.
%
%   Output:
% 
%   - obj  : An object of class nb_dateInExpr.
% 
%   Examples:
% 
%   obj = nb_dateInExpr('2012Q1');
% 
% See also: 
% nb_date
% 
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
 
    properties
        
        % The date the object represents.
        date   = nb_date();
        
    end
    
    methods
        
        function obj = nb_dateInExpr(date)      
            
            if nargin == 0
               return 
            end
            
            if ischar(date)
                date = nb_date.date2freq(date);
            elseif isa(date,'nb_date')
                % Do nothing
            elseif isnumeric(date)
                date = nb_year(date);
            else 
                error([mfilename ':: the date input must either be an ',...
                    'object of class nb_date, a one line char or an integer.'])
            end

            % Assign properties
            obj.date = date;
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
             
        function obj = compare(obj,aObj)
            obj.date = nb_date.min(obj.date,aObj.date);
        end
        function obj = compareMax(obj,aObj)
            obj.date = nb_date.max(obj.date,aObj.date);
        end
        function obj = emptyObject(obj)
            obj.date = [];
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
