classdef nb_num < nb_term
% Description:
%
% A class for representing a number. Used by the nb_simplifyEq class.
%
% Superclasses:
% nb_term
%
% Constructor:
%
%   obj = nb_num(value);
% 
%   Input:
%
%   - value : A scalar double. E.g. 1.
%
%   Output:
% 
%   - obj  : An object of class nb_num.
%
%   Examples:
%
%   base = nb_num(1);
%
% See also:
% nb_term
%
% Written by Kenneth Sæterhagen Paulsen    
   
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
        
        % The number as a scalar double.
        value = 0;
         
    end
    
    methods 
        
        function obj = nb_num(value)
            if nargin < 1
                value = 0;
            end
            if ~isnumeric(value)
                error([mfilename ':: The input must be numeric.'])
            end
            if isscalar(value)
                obj.value = value;
            else
                siz   = size(value);
                nobj  = numel(value);
                obj   = obj(ones(1,nobj),1);
                value = value(:);
                for ii = 1:nobj
                    obj(ii).value = value(ii);
                end
                obj = reshape(obj,siz);
            end
        end
        
    end
    
    methods (Access=protected)
        varargout = callLogOnSub(varargin)
        varargout = callPlusOnSub(varargin)
        varargout = callPowerOnSub(varargin)
        varargout = callTimesOnSub(varargin)
    end
    
end
