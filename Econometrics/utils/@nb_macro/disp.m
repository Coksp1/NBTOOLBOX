function disp(obj)
% Syntax:
%
% disp(obj)
%
% Description:
%
% Displaying the macro variable in the command window.
% 
% Input:
% 
% - obj : A nb_macro object of any size.
% 
% Written by Kenneth Sæterhagen Paulsen  

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    disp(nb_createLinkToClass(obj,'nb_macro'));
    disp(' ')

    obj  = obj(:);
    nobj = size(obj,1);
    c    = cell(nobj,3);
    for ii = 1:nobj
        c{ii,1} = obj(ii).name;
        c{ii,2} = '=';
        c{ii,3} = nb_any2String(obj(ii).value);
    end
    disp(cell2charTable(c));

end
