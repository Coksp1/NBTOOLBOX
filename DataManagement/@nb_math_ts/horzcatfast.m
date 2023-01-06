function obj = horzcatfast(varargin)
% Syntax:
%
% obj = horzcatfast(varargin)
%
% Description:
%
% Horizontal concatenation
% 
% The start or end dates cannot differ.
% 
% Input:
%
% - varargin : Optional number of nb_math_ts objects
% 
% Output:
%
% obj        : An object of class nb_math_ts with the input objects
%              data are horizontally concatenated
%
% See also
% nb_math_ts.horzcat
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = varargin{1};
    if nargin == 1
        return
    elseif nargin == 2
        % Assign properties
        obj.data = [varargin{1}.data,varargin{2}.data];
    else
        varargin = cellfun(@(x)x.data,varargin,'uniformOutput',false);
        obj.data = horzcat(varargin{:});
    end

end
