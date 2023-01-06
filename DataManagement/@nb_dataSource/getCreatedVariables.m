function created = getCreatedVariables(obj)
% Syntax:
%
% created = getCreatedVariables(obj)
%
% Description:
%
% Get a N x 2 table of the variables created using the createVariable
% method. The first column list the created variables, while the second
% column list the expressions.
% 
% Input:
% 
% - obj : An object that is a subclass of nb_dataSource.
% 
% Output:
% 
% - created : A N x 2 cell array. See description of this method for more.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    links    = get(obj,'links');
    if ~nb_isempty(links)
        subLinks = links.subLinks;
        nRows    = 0;
        for ii = 1:numel(subLinks)
           optThis = subLinks(ii).operations;
           for jj = 1:length(optThis)
               if isa(optThis{jj}{1},'function_handle') && strcmpi(func2str(optThis{jj}{1}),'createVariable')
                   nRows = nRows + 1;
               end
           end
        end

        % Fill in the table
        created = cell(nRows,2);
        kk      = 1;
        for ii = 1:numel(subLinks)
           optThis = subLinks(ii).operations;
           for jj = 1:length(optThis)
               if isa(optThis{jj}{1},'function_handle') && strcmpi(func2str(optThis{jj}{1}),'createVariable')
                   created(kk,1) = optThis{jj}{2}{1};
                   created(kk,2) = optThis{jj}{2}{2};
                   kk            = kk + 1;
               end
           end
        end
    else
        created = [];
    end

end
