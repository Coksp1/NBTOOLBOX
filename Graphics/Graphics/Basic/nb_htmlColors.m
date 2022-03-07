function colors = nb_htmlColors(endc)
% Syntax:
%
% colors = nb_htmlColors(endc)
%
% Description:
%
% Create a color list for use in colored pop-up menus
% 
% Input:
% 
% - endc   : A n x 3 double with the RGB colors. 
% 
% Output:
% 
% - colors : A cell array with size n.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    colors = cell(size(endc,1),1);
    for a = 1:size(endc,1)
        colors{a} = ['<HTML><BODY bgcolor="rgb(' num2str(endc(a,1)*255) ',' ...
                     num2str(endc(a,2)*255) ',' num2str(endc(a,3)*255) ')">  '...
                    '    <PRE>                  </PRE></BODY></HTML>'];
    end
    
end
