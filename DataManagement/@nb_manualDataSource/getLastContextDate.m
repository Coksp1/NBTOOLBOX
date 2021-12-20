function lastContextDate = getLastContextDate(obj)

    lastVintageDates = cell(1,size(obj.funcs,2)); % Doc is inherited!
    for ii = 1:size(obj.funcs,2)
       datasets = obj.funcs{ii}(); 
       if ~isa(datasets,'nb_ts')
           error([mfilename ':: The function ' func2str(obj.funcs{ii}), ' must return a nb_ts object.'])
       elseif isempty(datasets)
           error([mfilename ':: An empty object was returned by the function; ' func2str(obj.funcs{ii})])
       end
       lastVintageDates{ii} = datasets{ii}.dataNames{end};
    end
    
    lastVintageDates = sort(lastVintageDates);
    lastContextDate  = lastVintageDates{end};
    
end
