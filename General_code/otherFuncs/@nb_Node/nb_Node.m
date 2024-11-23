classdef nb_Node < handle
% Syntax:
%     
% obj = nb_Node(element,id)
%
% Superclasses:
%
% handle
%     
% Description:
%     
% A class for storing any type an include it in a list (nb_list 
% object)    
%     
% Constructor:
%     
%     obj = nb_Node(element,id)
%     
%     Input:
% 
%     - element : Any type 
% 
%     - id      : A string with an identifier.
% 
%     Output:
% 
%     - obj     : An object of class nb_Node
%
%     Examples:
%   
%     obj = nb_Node(2,'A number with value 2');
%
% See also:
% nb_list
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties 
       
        % The element stored by the node. Can be of any class.
        element = [];
        
        % The identifier associated with the stored object 
        id      = '';
        
        % The next object (when stored in a nb_List object)
        next    = [];
        
        % The previous object (when stored in a nb_List object)
        prev    = [];
        
    end
    
    methods
   
        function obj = nb_Node(element,id)
            
            obj.element = element;
            obj.id      = id;
            
        end
        
        varargout = getElement(varargin)

        varargout = getID(varargin)
        
        varargout = getNext(varargin)
        
        varargout = getPrev(varargin)
        
        varargout = hasNext(varargin)
        
        varargout = setElement(varargin)
        
        varargout = setNext(varargin)
        
        varargout = setPrev(varargin)
        
    end
    
end
