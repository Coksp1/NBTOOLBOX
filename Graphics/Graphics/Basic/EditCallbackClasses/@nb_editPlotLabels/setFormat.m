function setFormat(gui)

    if strcmpi(gui.type,'all')
        updateFormat(gui,gui.format);
        return
    end

    format           = getFormatUpALevel(gui);
    [changed,format] = checkFormat(format,gui.format);
    if changed
        
        switch lower(gui.type)
            case 'cell'
                format.index = gui.index;
            case 'row'
                format.index = [gui.index(2),gui.index(3)];
            case 'column'
                format.index = [gui.index(1),gui.index(3)];
        end
        updateFormat(gui,format);
        
    else
        if ~strcmpi(gui.type,'all')
            removeFormat(gui);
        end
    end

end

%==========================================================================
function [changed,newFormat] = checkFormat(format,newFormat)

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    changed = false;
    fields  = fieldnames(newFormat);
    fields  = fields(~strcmpi('index',fields));
    for ii = 1:length(fields)
        if isequal(format.(fields{ii}),newFormat.(fields{ii}))
            newFormat.(fields{ii}) = [];
        else
            changed = true;
        end
    end
    
end
