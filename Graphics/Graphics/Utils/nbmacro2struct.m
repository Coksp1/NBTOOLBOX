function s = nbmacro2struct(nbMacro)
s = struct();
fNames = {nbMacro.name};
for ii = 1:numel(fNames)
    if strcmp(fNames{ii}, 'isnb') == 0
        s.(fNames{ii}) = nbMacro(ii).value;
    end
end

end
