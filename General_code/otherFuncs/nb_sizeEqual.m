function ret = nb_sizeEqual(input,shouldBeSize)
% Syntax:
%
% ret = sizeEqual(input,shouldBeSize)
%
% Description:
%
% Test if the input is of a given size 
% 
% Input:
% 
% - input        : Any object
%
% - shouldBeSize : A 1 x n double. Where n must match the potensial output
%                  size of size(input). If some elments are nan those
%                  dimensions are unrestricted.
% 
% Output:
% 
% - ret          : True if the size match shouldBeSize. If the input 
%                  shouldBeSize does not match the output from size(input)
%                  ret is returned as false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    isSize = size(input);
    if size(isSize,2) ~= size(shouldBeSize,2)
        diff   = size(shouldBeSize,2) - size(isSize,2);
        if diff > 0
            isSize = [isSize,ones(1,diff)];
        else
            ret = false;
            return
        end
    end
    ind               = isnan(shouldBeSize);
    shouldBeSize(ind) = isSize(ind);
    ret               = all(isSize == shouldBeSize);

end
