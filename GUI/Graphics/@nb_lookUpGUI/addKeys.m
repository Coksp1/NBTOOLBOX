function addKeys(gui, newKeys)
% Syntax:
%
% addKeys(gui, newKeys)
%
% Description:
%
% Part of DAG. Add given keys to the lookupmatrix (i.e. the table)
% 
% Written by Kenneth Sæterhagen Paulsen
   
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Do not add keys that are already in table
    newKeys = setdiff(newKeys, gui.keys);
    newData = repmat(newKeys', 1, 3);

    % Update table data
    current = get(gui.table,'data');
    new     = [current; newData];
    set(gui.table,'data',new);

    for ii = 1:size(new,1)
        
        ind = strfind(new{ii,2},'\\');
        if ~isempty(ind)
            splitted  = regexp(new{ii,2},'\s\\\\\s','split');
            new{ii,2} = char(splitted);
        end
        
        ind = strfind(new{ii,3},'\\');
        if ~isempty(ind)
            splitted  = regexp(new{ii,3},'\s\\\\\s','split');
            new{ii,3} = char(splitted);
        end
        
    end

    gui.plotter.lookUpMatrix = new;
    
end
