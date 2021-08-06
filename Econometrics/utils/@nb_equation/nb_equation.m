classdef nb_equation < nb_term
% Description:
%
% A class for representing an equation with a set of nb_term objects.
%
% Superclasses:
% nb_term
%
% Constructor:
%
%   obj = nb_equation(expr);
% 
%   Input:
%
%   - expr : Expression to simplify, as a one line char or a cellstr.
%
%   Output:
% 
%   - obj  : An object of class nb_equation.
%
%   Examples:
%
%   terms = nb_equation('x+x*y'); 
%
% See also:
% nb_term
%
% Written by Kenneth Sæterhagen Paulsen    
   
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    methods 
        
        function obj = nb_equation(operator,terms)
            if nargin == 0
                obj.operator = '+';
                return
            end
            obj.operator = operator;
            obj.terms    = terms(:); % Will be sorted in set.terms
        end
   
    end
    
    methods (Static=true)
        varargout = initialize(varargin);
    end
    
    methods (Access=protected) 
        varargout = callLogOnSub(varargin)
        varargout = callPlusOnSub(varargin)
        varargout = callPowerOnSub(varargin)
        varargout = callTimesOnSub(varargin)
    end
    
end
