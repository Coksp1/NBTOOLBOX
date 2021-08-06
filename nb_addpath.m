function nb_addpath(paths)
% Syntax:
%
% nb_addpath(paths)
%
% Description:
%
% Fixed a bu in the addpath function made by MATLAB, in the sence that it
% much more quickly detect already added paths.
% 
% Input:
% 
% - paths : A string (or a cellstr) with the added path(s)
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if ischar(paths)
        paths = cellstr(paths);
    end

    existing = path();
    existing = regexp(existing,';','split');
    ind      = ~ismember(paths,existing);
    paths    = paths(ind);
    if ~isempty(paths)
        addpath(paths{:});
    end

end
