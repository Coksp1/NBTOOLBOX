function obj = rdivide(obj,another)
% Syntax:
%
% obj = rdivide(obj,another)
%
% Description:
%
% Division operator (./) for nb_symMatrix objects.
% 
% Input:
% 
% - obj     : A nb_symMatrix object or double.
%
% - another : A nb_symMatrix object or double.
% 
% Output:
% 
% - obj     : A nb_symMatrix object.
%
% See also:
% nb_symMatrix.times
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    [obj,another,err] = checkTypes(obj,another,mfilename);
    if isempty(err)
        error(err);
    end
    [obj,another,err] = checkSizes(obj,another);
    if isempty(err)
        error(err);
    end
    obj = callMethod(obj,another,@rdivide);
    
end
