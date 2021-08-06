function style = getStyle(obj, type)
    switch lower(type)
        case 'blank'
            style = obj.style(1);
        case 'firstrow'
            style = obj.style(3);
        case 'firstcolumn'
            style = obj.style(4);
        case 'evenrow'
            style = obj.style(5);
        case 'evencolumn'
            style = obj.style(6);
        otherwise
            style = obj.style(2);
    end
end
