function obj = assignAll(obj,field,value)
% Syntax:
%
% obj = assignAll(obj,field,alue)
%
% Description:
%
% Assign all elements of an array of nb_struct objects.
%
% PS: This is the same as doing this with a normal struct;
%     [obj(:).fieldName] = deal(value)
% PS: The output is to make this method generic to the assignAll function
%     acting on a struct. It is strictly not needed in this case, as the
%     nb_struct is a handle.
% 
% Input:
% 
% - obj   : A N x M x P nb_struct object.
% 
% - field : The field to assign of all elements.
%
% - value : The value to assign to all elements.
%
% Examples:
%
% obj = nb_struct(4,{'fieldName'})
% obj = assignAll(obj,'fieldName',2);
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~nb_isOneLineChar(field)
        error('The field input must be a one line char!')
    end
    siz = size(obj);
    if size(siz) > 3
        error('The input cannot have size of dimension 4 greater than 1!')
    elseif size(siz) < 3
        siz = [siz,1];
    end

    for ii = 1:siz(1)
        for jj = 1:siz(2)
            for kk = 1:siz(3)
                obj.s(ii,jj,kk).(field) = value;
            end
        end
    end

end
