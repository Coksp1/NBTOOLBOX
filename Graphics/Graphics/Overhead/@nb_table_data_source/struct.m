function s = struct(obj)
% Syntax:
%
% s = struct(obj)
%
% Description:
%
% Convert object to struct
% 
% Input:
% 
% - obj : An object of class nb_table_data_source
% 
% Output:
% 
% - s   : A struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.returnLocal = true;

    s     = struct();
    props = properties(obj);
    for ii = 1:length(props)
        
        switch lower(props{ii})
            
            case 'annotation'
                
                if isa(obj.annotation,'nb_annotation')
                    if isvalid(obj.annotation)
                        ann = struct(obj.annotation);
                    else
                        ann = [];
                    end
                elseif isempty(obj.annotation)
                    ann = [];
                else

                    tAnn = obj.annotation;
                    sAnn = length(tAnn);
                    ann  = cell(1,sAnn);
                    kk   = 1;
                    for jj = 1:sAnn
                        if isvalid(tAnn{jj})
                            ann{kk} = struct(tAnn{jj});
                            kk      = kk + 1;
                        end
                    end

                    % Remove empty cell (Due to invalid annotation 
                    % objects)
                    ind = ~cellfun('isempty',ann);
                    ann = ann(ind);
                    ann = {ann};

                end
                
                s.annotation = ann;
            
            case 'db'
            
                if iscell(obj.DB)
                    s.DB = obj.DB;
                else
                    s.DB = struct(obj.DB);
                end
                
            case 'endtable'
                
                if isa(obj.endTable,'nb_date')
                    date = toString(obj.endTable);
                else
                    date = obj.endTable;
                end
                s.endTable = date;
                
            case 'table'
                
                s.table = struct(obj.table);
                
            case 'starttable'
                
                if isa(obj.startTable,'nb_date')
                    date = toString(obj.startTable);
                else
                    date = obj.startTable;
                end
                s.startTable = date;
                
            otherwise
                
                s.(props{ii}) = obj.(props{ii});
        end
        
    end
    
    % Do the protected properties we need to keep as well
    %-----------------------------------------------------
    figTitleObjectE = obj.figTitleObjectEng;
    if isa(figTitleObjectE,'nb_figureTitle')
        figTitleObjectE = struct(figTitleObjectE);
    end
    s.figTitleObjectEng = figTitleObjectE;

    figTitleObjectN = obj.figTitleObjectNor;
    if isa(figTitleObjectN,'nb_figureTitle')
        figTitleObjectN = struct(figTitleObjectN);
    end
    s.figTitleObjectNor = figTitleObjectN;

    footerObjectE = obj.footerObjectEng;
    if isa(footerObjectE,'nb_footer')
        footerObjectE = struct(footerObjectE);
    end
    s.footerObjectEng = footerObjectE;

    footerObjectN = obj.footerObjectNor;
    if isa(footerObjectN,'nb_footer')
        footerObjectN = struct(footerObjectN);
    end
    s.footerObjectNor = footerObjectN;
    
    obj.returnLocal = false;
        
end
