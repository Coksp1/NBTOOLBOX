classdef nb_List
% Syntax:
%     
% obj = nb_List()
% 
% Description:
%     
% This is a class for storing objects. Using a list structure    
%     
% Constructor:
%     
%     obj = nb_List()
%     
%     The empty constructor of the nb_List class
%     
% See also:
% nb_Node
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The first nb_Node object of the list 
        first = [];
        
        % A cellstr with the identifiers of the stored objects.
        ids   = {};
        
        % The last nb_Node object of the list
        last  = [];
        
    end
    
    methods
        
        function obj = nb_List()
            
        end
        
        varargout = add(varargin)
        
        varargout = get(varargin)
        
        varargout = getFirst(varargin)
        
        varargout = getLast(varargin)
        
        varargout = getNumberOfStoredObjects(varargin)
        
        varargout = remove(varargin)
        
        varargout = reset(varargin)
        
    end
       
end
