function to = mergeCells(to, from, varargin)
    
    if isscalar(from)
            from = repmat(from, size(to));
    end

    overwrite = any(ismember(varargin, 'overwrite'));
    
    fields = fieldnames(from);
    for y = 1:size(to, 1)
        for x = 1:size(to, 2)
            for i = 1:length(fields)
                field = fields{i};
                if ~isfield(to, field) || ...
                        isempty(to(y, x).(field)) || ...
                        overwrite
                    to(y, x).(field) = from(y, x).(field);
                end
            end
        end
    end
    
end
