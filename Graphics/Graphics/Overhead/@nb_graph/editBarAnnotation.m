function editBarAnnotation(obj,~,~)
% Syntax:
%
% editBarAnnotation(obj,~,~)
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

            ann = ann{ind};
            nb_editBarAnnotation(ann);

        end

    end

end
