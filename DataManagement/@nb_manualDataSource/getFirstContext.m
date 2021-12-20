function data = getFirstContext(obj,variables)
  
    if nargin < 2 % Doc is inheritied from nb_connector.getFristContext
        variables = {};
    end

    data = getTS(obj,date,variables);
    data = data(:,:,1);
    if ~isempty(data.userData)
        data.userData = data.userData(1,:);
    end
           
end
