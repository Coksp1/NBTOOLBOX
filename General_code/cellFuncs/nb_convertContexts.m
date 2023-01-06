function contexts = nb_convertContexts(contexts,extraInMessage)
% Syntax:
%
% contexts = nb_convertContexts(contexts)
%
% Description:
%
% Convert from a cellstr of elements on the format 'yyyymmdd' to a double
% vector.
% 
% Input:
% 
% - contexts : Either a 1 x N or N x 1 cellstr, where all the elements are
%              on the format 'yyyymmdd'.
% 
% Output:
% 
% - contexts : A N x 1 double vector.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        extraInMessage = '';
    end

    contexts = char(contexts(:));
    if ~any(size(contexts,2) == [8,12,14])
        error([mfilename ':: All elements of the input ' extraInMessage 'must have the format ''yyyymmdd'' or ''yyyymmddhhnnss''.'])
    end
    contexts = str2num(contexts); %#ok<ST2NM>
    if isempty(contexts)
        error([mfilename ':: All elements of the input ' extraInMessage 'must have the format ''yyyymmdd'' or ''yyyymmddhhnnss''.'])
    end
    
end
