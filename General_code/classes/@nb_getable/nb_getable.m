classdef (Abstract) nb_getable < handle
% Description:
%
% A abstract class that can be implemented to make it possible to get
% properties of an object using a get method.
%
% Superclasses:
% 
% handle
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    methods 
        varargout = get(varargin)
    end

end
