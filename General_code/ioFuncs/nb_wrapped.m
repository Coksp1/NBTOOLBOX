function wrapped = nb_wrapped(string,max)
% Syntax:
%
% wrapped = nb_wrapped(string,max)
%
% Description:
%
% Wrap line at spaces, where each line of the wrapped text is a maximum
% number of chars.
% 
% Input:
% 
% - string : A one line char.
%
% - max    : Max number of char in one line. 
% 
% Output:
%
% - wrapped : A cellstr.
%
% Examples:
% s = 'This is a line that must be wrapped. Can you help me?'
% c = nb_wrapped(s, 40)
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ind     = [find(isspace(string)),length(string)];
    jj      = 1;
    brk     = 0;
    wrapped = cell(ceil(length(string)/max),1);
    for ii = 1:length(ind)-1
        t_ind = ind(ii+1);
        if t_ind - brk > max
            wrapped{jj} = string(brk+1:ind(ii)-1);
            jj          = jj + 1;
            brk         = ind(ii);
        end
    end
    wrapped{jj} = string(brk+1:end); % Rest of line
    ind         = cellfun(@isempty, wrapped);
    wrapped     = wrapped(~ind);
    
end
