function obj = plus(obj,another)
% Syntax:
%
% obj = plus(obj,another)
%
% Description:
%
% Plus operator (+) for nb_symMatrix objects.
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
% nb_symMatrix.minus, nb_symMatrix.uplus
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen
    
    [obj,another,err] = checkTypes(obj,another,mfilename);
    if isempty(err)
        error(err);
    end
    [obj,another,err] = checkSizes(obj,another);
    if isempty(err)
        error(err);
    end
    obj = callMethod(obj,another,@plus);
    
end
