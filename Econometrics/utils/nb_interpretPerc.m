function newPerc = nb_interpretPerc(perc,inverse)
% Syntax:
%
% newPerc = nb_interpretPerc(perc,inverse)
%
% Description:
%
% 
% 
% Input:
% 
% - perc    : Depend on the inver input.
%
% - invers  : 
%
%   > inverse == true  : Input must be a 1 x N double with percentiles
%                        in the format [5,15,25,35,65,75,85,95], while
%                        the output is percentiles in the format 
%                        [0.3,0.5,0.7,0.9].
%   > inverse == false : Switch input and output from the inverse == true
%                        case.
% 
% Output:
% 
% - newPerc : Depend on the inverse input.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if inverse

        newPerc = [];
        nPerc   = size(perc,2);
        if rem(nPerc,2) ~= 0
            newPerc = 0;
            nPerc   = nPerc - 1;  
        end
        nPerc   = nPerc/2;
        perc    = perc(1:nPerc)/100;
        perc    = fliplr(1 - 2*perc);
        newPerc = [newPerc,perc];
        
    else

        low     = fliplr(abs(perc/2 - 0.5));
        up      = perc/2 + 0.5;
        newPerc = unique([low,up])*100;
        
    end
    
end
