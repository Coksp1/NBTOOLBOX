function contexts = nb_convertContexts(contexts)
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
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    contexts = char(contexts(:));
    if size(contexts,2) ~= 8
        error([mfilename ':: All elements of the input must have the format ''yyyymmdd''.'])
    end
    contexts = str2num(contexts); %#ok<ST2NM>
    if isempty(contexts)
        error([mfilename ':: All elements of the input must have the format ''yyyymmdd''.'])
    end
    
end
