classdef nb_ss  < double
% Description:
%
% Create a class representing a steady-state variable. Same as a double
% but indexing like (-d), (d) or (+1) on a scalar object just return the 
% same value as the original data (otherwise indexing works as a normal 
% double).
%
% Superclasses:
%
% double
%
% Constructor:
%
%   obj = nb_ss(num)
% 
%   Input:
%
%   - num : A double.
% 
%   Output:
% 
%   - obj : A nb_ss object array with same size as num.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    methods
        
        function this = nb_ss(varargin)
            this = this@double(varargin{:});
        end
        
        function obj = plus(obj,another)
           d   = plus@double(obj,another);
           obj = nb_ss(d);
        end
        
        function obj = minus(obj,another)
           d   = minus@double(obj,another);
           obj = nb_ss(d);
        end
        
        function obj = rdivide(obj,another)
           d   = rdivide@double(obj,another);
           obj = nb_ss(d);
        end
        
        function obj = ldivide(obj,another)
           d   = ldivide@double(obj,another);
           obj = nb_ss(d);
        end
        
        function obj = mrdivide(obj,another)
           d   = mrdivide@double(obj,another);
           obj = nb_ss(d);
        end
        
        function obj = mldivide(obj,another)
           d   = mldivide@double(obj,another);
           obj = nb_ss(d);
        end
        
        function obj = times(obj,another)
           d   = times@double(obj,another);
           obj = nb_ss(d);
        end
        
        function obj = mtimes(obj,another)
           d   = mtimes@double(obj,another);
           obj = nb_ss(d);
        end
        
        function obj = power(obj,another)
           d   = power@double(obj,another);
           obj = nb_ss(d);
        end
        
        function obj = mpower(obj,another)
           d   = mpower@double(obj,another);
           obj = nb_ss(d);
        end
        
        function obj = uminus(obj)
           d   = uminus@double(obj);
           obj = nb_ss(d);
        end
        
        function obj = uplus(obj)
            % Do nothing
        end
        
        function obj = log(obj)
           d   = log@double(obj);
           obj = nb_ss(d);
        end
        
        function obj = exp(obj)
           d   = exp@double(obj);
           obj = nb_ss(d);
        end
        
        function obj = sqrt(obj)
           d   = sqrt@double(obj);
           obj = nb_ss(d);
        end
        
        function obj = steady_state(obj)
            % Do nothing
        end
        
        function obj = steady_state_init(obj)
            % Do nothing
        end
        
        function obj = logncdf(obj,m,k)
            d   = nb_distribution.lognormal_cdf(double(obj),double(m),double(k));
            obj = nb_ss(d);
        end
        
        function obj = lognpdf(obj,m,k)
            d   = nb_distribution.lognormal_pdf(double(obj),double(m),double(k));
            obj = nb_ss(d);
        end
        
        function obj = normcdf(obj,m,k)
            d   = nb_distribution.normal_cdf(double(obj),double(m),double(k));
            obj = nb_ss(d);
        end
        
        function obj = normpdf(obj,m,k)
            d   = nb_distribution.normal_pdf(double(obj),double(m),double(k));
            obj = nb_ss(d);
        end
        
        function disp(obj)
            disp@double(obj);
        end
        
        function varargout = subsref(obj,s)
            
            switch s(1).type
                case '()'
                    if isscalar(obj)
                        % Make (-1) (+1) return the same as object itself
                        varargout{1} = obj;
                    else
                        try
                            [varargout{1:nargout}]  = builtin('subsref', obj, s);
                        catch
                            builtin('subsref', obj, s);
                        end
                    end
                otherwise
                    try
                        [varargout{1:nargout}]  = builtin('subsref', obj, s);
                    catch
                        builtin('subsref', obj, s);
                    end
            end
            
        end
        
    end
    
end
