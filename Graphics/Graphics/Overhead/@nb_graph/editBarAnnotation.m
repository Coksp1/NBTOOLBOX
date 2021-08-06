function editBarAnnotation(obj,~,~)
% Syntax:
%
% editBarAnnotation(obj,~,~)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

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

            ann = ann{ind};
            nb_editBarAnnotation(ann);

        end

    end

end
