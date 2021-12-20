function obj = horzcat(varargin)
% Syntax:
%
% obj = horzcat(varargin)
%
% Description:
%
% Horizontal concatenation
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin == 1
        obj = varargin{1};
        return
    end

    obj1     = varargin{1};
    obj2     = varargin{2};
    varargin = varargin(3:end);
    if isempty(obj1)
        obj = horzcat(obj2,varargin{:});
        return
    elseif isempty(obj2)
        obj = horzcat(obj1,varargin{:});
        return
    end
    
    dim1 = size(obj1,1);
    if dim1 ~= size(obj2,1)
        error([mfilename ':: Concatenation not possible due to dimension mismatch.'])
    end
    
    if isnumeric(obj1)
        obj1 = nb_distribution.double2Dist(obj2);
    elseif isnumeric(obj2)
        obj2 = nb_distribution.double2Dist(obj2);
    end
    
    s1            = size(obj1,2);
    s2            = size(obj2,2);
    s             = s1 + s2;
    obj(dim1,s)   = nb_distribution;
    obj(:,1:s1)   = obj1;
    obj(:,s1+1:s) = obj2;
    
    % Concatenate with the rest
    obj = horzcat(obj,varargin{:});

end
