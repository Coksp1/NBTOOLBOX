classdef (Abstract) nb_objectInExpr
% Description:
%
% A class representing an object that can be used in nb_eval to get the
% results of objects used in an expression.
%    
% See also: 
% nb_dateInExpr, nb_logicalInExpr
% 
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
 
    %======================================================================
    % Public and abstract methods
    %======================================================================
    methods (Abstract=true)
             
        varargout = callfun(obj,varargin)
        obj       = convert(obj,freq,method,varargin)
        obj       = denton(obj,z,k,type,d)
        disp(obj)
        obj       = expand(obj,newStartDate,newEndDate,type,warningOff)
        obj       = extrapolate(obj,toDate,varargin)
        obj       = fillNaN(obj,date)
        obj       = window(obj,startDateWin,endDateWin,pages)
        
    end

    %======================================================================
    % Protected and abstract methods
    %======================================================================
    methods (Abstract=true,Access=protected)
             
        obj = compare(obj,aObj)
        obj = compareMax(obj,aObj)
        obj = emptyObject(obj)
        
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
