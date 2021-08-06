function delete(obj)

    % Remove it form its parent
    if isa(obj.parent, 'nb_axes')
        if isvalid(obj.parent)
            obj.parent.removeChild(obj);
        end
    end

    if strcmpi(obj.deleteOption,'all')
        obj.deleteChildren();
    end

end
