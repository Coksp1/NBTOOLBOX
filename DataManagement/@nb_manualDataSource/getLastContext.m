function data = getLastContext(obj,variables)
  
    if nargin < 2 % Doc is inheritied from nb_connector.getLastContext
        variables = {};
    end

    datasets = cell(1,size(obj.funcs,2));
    vars     = cell(1,size(obj.funcs,2));
    for ii = 1:size(obj.funcs,2)
       datasets{ii} = obj.funcs{ii}(); 
       if ~isa(datasets{ii},'nb_ts')
           error([mfilename ':: The function ' func2str(obj.funcs{ii}), ' must return a nb_ts object.'])
       elseif isempty(datasets{ii})
           error([mfilename ':: An empty object was returned by the function; ' func2str(obj.funcs{ii})])
       end
       datasets{ii} = window(datasets{ii},'','','',datasets{ii}.numberOfDatasets);
       vars{ii}     = datasets{ii}.variables{1};
    end
    if ~isempty(variables)
        ind      = ismember(vars,variables);
        datasets = datasets(ind); 
    end
    data = horzcat(datasets{:}); 
        
end
