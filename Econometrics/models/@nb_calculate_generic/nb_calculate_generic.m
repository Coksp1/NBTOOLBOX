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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
   
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
    
    methods (Static=true)
        
        function calc = rename(calc,renameVariables)
            
            if isempty(renameVariables)
                return
            end
            if length(calc.variables) ~= length(renameVariables)
                error(['The length of the renamedVariables must be equal ',...
                       'to the number of calculated factors (',...
                       int2str(length(calc.variables)) ').'])
            end
            calc = renameMore(calc,'variables',calc.variables,renameVariables);
           
        end
        
    end
    
end

