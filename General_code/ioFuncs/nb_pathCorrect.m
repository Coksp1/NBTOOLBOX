function path = nb_pathCorrect(path)
% Syntax:
%
% path = nb_pathCorrect(path)
%
% Description:
%
% Replace \ with \\ in path name.
%
% Inputs:
%
% - path : A 1xN char or cellstr.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen


    ind1  = strfind(path,'\');
    ind1T = ind1;
    ind2  = strfind(path,'\\');
    if isempty(ind2)       
        path = strrep(path,'\','\\');  
    else
        for ii = 1:length(ind1)
            if ~any(ind1(ii) == ind2) && ~any(ind1(ii) == ind2 + 1)
                path  = [path(1:ind1T(ii) - 1), '\\',path(ind1T(ii) + 1:end)];
                ind1T = ind1T + 1;
            end
        end
    end
        
end
