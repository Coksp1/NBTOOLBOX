classdef (Abstract) nb_calculate_generic
% Description:
%
% A superclass for all classes that has a calculate method. 
%
% Constructor:
%
%   This class is abstract, and has no constructor,
% 
% See also:
% nb_calculate_vintages
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
   
    methods (Sealed=true)
        
        varargout = calculate(varargin)
        
    end
    
    methods (Abstract=true)
        
        % Syntax:
        %
        % calc = getCalculated(obj)
        %
        % Description:
        %
        % Get calculated series from model.
        % 
        % Input:
        % 
        % - obj : A scalar nb_calculate_generic object.
        % 
        % Output:
        % 
        % - calc : An object of class nb_ts.
        %
        % Written by Kenneth Sæterhagen Paulsen
        calc = getCalculated(obj)
        
    end
    
end

