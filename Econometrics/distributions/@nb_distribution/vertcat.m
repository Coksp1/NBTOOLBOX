function obj = vertcat(varargin)
% Syntax:
%
% obj = vertcat(varargin)
%
% Description:
%
% Vertical concatenation
% 
% Input:
% 
% - varargin : Either an object of class nb_distribution or an object of
%              class double
% 
% Output:
% 
% - obj      : An object of class nb_distribution
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin == 1
        obj = varargin{1};
        return
    end

    obj1     = varargin{1};
    obj2     = varargin{2};
    varargin = varargin(3:end);
    if isempty(obj1)
        obj = vertcat(obj2,varargin{:});
        return
    elseif isempty(obj2)
        obj = vertcat(obj1,varargin{:});
        return
    end
    
    dim2 = size(obj1,2);
    if dim2 ~= size(obj2,2)
        error([mfilename ':: Concatenation not possible due to dimension mismatch.'])
    end
    
    if isnumeric(obj1)
        obj1 = nb_distribution.double2Dist(obj2);
    elseif isnumeric(obj2)
        obj2 = nb_distribution.double2Dist(obj2);
    end
    
    s1            = size(obj1,1);
    s2            = size(obj2,1);
    s             = s1 + s2;
    obj(s,dim2)   = nb_distribution;
    obj(1:s1,:)   = obj1;
    obj(s1+1:s,:) = obj2;
    
    % Concatenate with the rest
    obj = vertcat(obj,varargin{:});

end
