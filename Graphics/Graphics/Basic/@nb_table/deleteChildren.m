function deleteChildren(obj)
    handles = obj.children;    
    for handle = handles
       if ishandle(handle)
           delete(handle);
       end
    end
    
    if ~isempty(obj.listeners)
        handles = obj.listeners;
        for ii = 1:length(handles)
            if isvalid(handles(ii))
                delete(handles(ii));
            end
        end
    end    
end
