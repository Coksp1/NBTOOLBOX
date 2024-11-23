function cout = nb_obj2cell(obj)
% Syntax:
%
% cout = nb_obj2cell(obj)
%
% Description:
%
% Convert object matrix to cell matrix
% 
% Input:
% 
% - obj : An user defined object of size M x N x P
% 
% Output:
% 
% - c   : A cell of size M x N x P
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [s1,s2,s3] = size(obj);
    cout       = cell(s1,s2,s3);
    for r = 1:s1
        for c = 1:s2
            for p = 1:s3
                cout{r,c,p} = obj(r,c,p);
            end
        end
    end    

end
