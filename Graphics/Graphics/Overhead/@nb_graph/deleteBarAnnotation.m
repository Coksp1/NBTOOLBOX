function deleteBarAnnotation(obj,~,~)
% Syntax:
%
% deleteBarAnnotation(obj,~,~)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ann = obj.annotation;

    if isempty(ann)
        nb_errorWindow('No bar annotation object exist.')
        return
    else

        ind = find(cellfun('isclass',ann,'nb_barAnnotation'),1);
        if isempty(ind)
            nb_errorWindow('No bar annotation object exist.')
            return
        else

            annObj = ann{ind};
            nb_confirmWindow('Are you sure you want to delete the selected object?',@notDelete,{@deleteAnnotation,annObj,obj,ind},'Delete Annotation');

        end

    end

    function deleteAnnotation(hObject,~,ann,obj,ind)

        ann.deleteOption = 'all';
        delete(ann);

        obj.annotation = [obj.annotation(1:ind-1), obj.annotation(ind+1:end)];

        % Close question window
        close(get(hObject,'parent'));

    end

    function notDelete(hObject,~)

        % Close question window
        close(get(hObject,'parent'));

    end

end
