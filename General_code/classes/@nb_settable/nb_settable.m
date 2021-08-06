classdef (Abstract) nb_settable < handle
% Description:
%
% A abstract class that can be implemented to be able to set properties
% using a set method.
%
% Superclasses:
% 
% handle
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Access=protected)
       
        % Set to false to prevent the obj to update for each time
        % a set.<propertyName> method is called.
        doUpdate            = true;
        
    end

    methods 
       
        varargout = set(varargin)
        
    end
    
    methods (Access=protected,Abstract=true)
       
        update(obj)
        
    end

end
