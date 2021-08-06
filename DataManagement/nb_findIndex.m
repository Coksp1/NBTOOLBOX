function index = nb_findIndex(cellstr1,cellstr2)
% Syntax:
%
% index = nb_findIndex(cellstr1,cellstr2)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    index = zeros(size(cellstr2));
    for ii = 1:length(cellstr1)
        index = index + strcmp(cellstr1{ii},cellstr2);
    end

end
