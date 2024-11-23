function applyTemplate(obj,chosen)
% Syntax:
%
% applyTemplate(obj,chosen)
%
% Description:
%
% Apply template to nb_graph_adv object.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    numG = size(obj.plotter,2);
    try
        t = obj.plotter(1).template.(chosen);
        t = t(1,ones(1,numG));
        for ii = 2:numG
           t(ii) = obj.plotter(ii).template.(chosen);
        end
    catch
        error([mfilename ':: The provided template does not exits; ' chosen])
    end
    
    if numG > 1
        t = rmfield(t,'position');
    end
    fields = fieldnames(t);
    for ii = 1:size(fields,1)
        if isprop(obj.plotter(1),fields{ii})
            for gg = 1:numG
                obj.plotter(gg).(fields{ii}) = t(gg).(fields{ii}); 
            end
        elseif strcmpi(fields{ii},'position1') && numG > 1
            obj.plotter(1).position = t(1).position1; 
        elseif strcmpi(fields{ii},'position2') && numG > 1
            obj.plotter(2).position = t(2).position2; 
        end
    end
    if numG > 1
        if isfield(t,'legLocation') 
            if strcmpi(t(1).legLocation,'outsideright') || strcmpi(t(1).legLocation,'outsiderighttop')
                for gg = 1:numG
                    obj.plotter(gg).legLocation = 'best';
                end
            end
        end
    end
    
    for gg = 1:size(obj.plotter,2)
        obj.plotter(gg).currentTemplate = chosen;
    end
    
end
