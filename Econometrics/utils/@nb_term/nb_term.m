classdef nb_term < matlab.mixin.Heterogeneous
% Description:
%
% The superclass of all mathematical terms included in an equation.
%
% Be aware that you still cannot call any method on a vector of any of
% them!
%
% Superclasses:
% matlab.mixin.Heterogeneous
%
% Subclasses:
% nb_base, nb_num, nb_equation
%
% See also:
% nb_base, nb_num, nb_equation
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (Dependent=true,SetAccess=protected)
       
        % The number of terms. As a scalar integer.
        numberOfTerms   = 0;
        
    end

    properties (SetAccess=protected)
        
        % Type of operator splitting the terms.
        operator    = '';
        
        % A vector of nb_term objects.
        terms       = [];
         
    end

    methods
        
        function value = get.numberOfTerms(obj)
            value = size(obj.terms,1);
        end
        
        function obj = set.terms(obj,value)
            obj.terms = value;
            if isa(obj,'nb_equation')
                obj.terms = sort(obj);
            end
        end
        
    end
    
    methods (Sealed=true)
        
        function disp(obj)
           disp(nb_createLinkToClass(obj));
           disp(' ') 
           disp(cellstr(obj));
        end
        
        varargout = cellstr(varargin);
        varargout = exp(varargin);
        varargout = gap(varargin);
        varargout = ismember(varargin);
        varargout = intersect(varargin);
        varargout = log(varargin);
        varargout = logncdf(varargin);
        varargout = lognpdf(varargin);
        varargout = minus(varargin);
        varargout = mpower(varargin);
        varargout = mrdivide(varargin);
        varargout = mtimes(varargin);
        varargout = normcdf(varargin);
        varargout = normpdf(varargin);
        varargout = plus(varargin);
        varargout = power(varargin);
        varargout = rdivide(varargin);
        varargout = sqrt(varargin);
        varargout = steady_state(varargin);
        varargout = times(varargin);
        varargout = uplus(varargin);
        varargout = uminus(varargin);
        varargout = union(varargin);
        varargout = unique(varargin);
        
    end
    
    methods(Sealed=true,Access=protected)
       varargout = seperateTerms(varargin); 
    end
    
    methods (Abstract=true)
        c = toString(obj)
    end
        
    methods (Access=protected,Abstract=true)
        obj = callLogOnSub(obj,another)
        obj = callPlusOnSub(obj,another)
        obj = callPowerOnSub(obj,another)
        obj = callTimesOnSub(obj,another)
    end
    
    methods (Static, Sealed, Access = protected)
        
        function default_object = getDefaultScalarElement
            default_object = nb_equation();
        end
        
    end
    
    methods (Static=true)
        varargout = correct(varargin);
        varargout = initialize(varargin);
        varargout = removePar(varargin);
        varargout = simplify(varargin);
        varargout = split(varargin);
    end
    
end
