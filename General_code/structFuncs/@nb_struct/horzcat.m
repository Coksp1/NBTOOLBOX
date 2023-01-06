function obj = horzcat(obj,varargin)
% Syntax:
%
% obj = horzcat(obj,varargin)
%
% Description:
%
% Horzontal concatenation of nb_struct objects. [obj,a]
% 
% Input:
% 
% - obj      : An object of class nb_struct.
%
% Optional inputs:
%
% - varargin : Object of class nb_struct.
% 
% Output:
% 
% - obj      : An object of class nb_struct.
%
% See also:
% nb_struct.vertcat
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    test = cellfun(@(x)isa(x,'nb_struct'),varargin);
    if any(~test)
        error('Cannot concatenate a nb_struct object with any other type of objects.')
    end
    sAdded = cellfun(@(x)x.s,varargin,'uniformOutput',false);
    obj.s  = [obj.s,sAdded{:}];

end
