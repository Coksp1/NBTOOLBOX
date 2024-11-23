function colors = htmlColors(endc)
% Syntax:
%
% colors = nb_selectVariableGUI.htmlColors(endc)
%
% Description:
%
% Part of DAG. Create a color list for use in colored pop-up menus
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    colors = cell(size(endc,1),1);
    if iscell(endc)
        for ii = 1:length(endc)
            if ischar(endc{ii})
                if strcmpi(endc{ii},'same')
                    colors{ii} = 'same';
                else
                    color      = nb_plotHandle.interpretColor(endc{ii});
                    colors{ii} = ['<HTML><FONT color="rgb(' num2str(color(1)*255) ',' ...
                                  num2str(color(2)*255) ',' num2str(color(3)*255) ')">'...
                                  endc{ii} '</FONT></HTML>'];
                end
            else   
                color      = endc{ii};
                colors{ii} = ['<HTML><BODY bgcolor="rgb(' num2str(color(1)*255) ',' ...
                              num2str(color(2)*255) ',' num2str(color(3)*255) ')">  '...
                              '    <PRE>                  </PRE></BODY></HTML>'];
            end
        end
    else
        for ii = 1:size(endc,1)
            colors{ii} = ['<HTML><BODY bgcolor="rgb(' num2str(endc(ii,1)*255) ',' ...
                          num2str(endc(ii,2)*255) ',' num2str(endc(ii,3)*255) ')">  '...
                          '    <PRE>                  </PRE></BODY></HTML>'];
        end
    end
    
end
