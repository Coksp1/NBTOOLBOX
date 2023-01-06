classdef nb_base < nb_term
% Description:
%
% A class for representing a variable. Used by the nb_term class.
%
% Superclasses:
% nb_term
%
% Constructor:
%
%   obj = nb_base(value,sign);
% 
%   Input:
%
%   - value : A variable name. E.g. 'x'.
%
%   Output:
% 
%   - obj  : An object of class nb_base.
%
%   Examples:
%
%   base = nb_base('x');
%
% See also:
% nb_term
%
% Written by Kenneth Sæterhagen Paulsen    
   
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
        
        % Base value, as a one line char.
        value       = 'x';
         
    end
    
    methods 
        
        function obj = nb_base(value)
            if nargin < 1
                value = 'x';
            end
            if nb_isOneLineChar(value)
                obj.value = value;
            else
                if ischar(value)
                    value = cellstr(value);
                end
                if ~iscellstr(value)
                    error([mfilename ':: The input must either be char or cellstr.'])
                end
                siz   = size(value);
                nobj  = numel(value);
                obj   = obj(ones(1,nobj),1);
                value = value(:);
                for ii = 1:nobj
                    obj(ii).value = value{ii};
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
