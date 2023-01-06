function index = nb_findIndex(cellstr1,cellstr2)
% Syntax:
%
% index = nb_findIndex(cellstr1,cellstr2)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    index = zeros(size(cellstr2));
    for ii = 1:length(cellstr1)
        index = index + strcmp(cellstr1{ii},cellstr2);
    end

end
