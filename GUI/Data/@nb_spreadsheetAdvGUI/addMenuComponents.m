function addMenuComponents(gui)
% Syntax:
%
% addMenuComponents(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen


    if isa(gui.data,'nb_modelDataSource')

        set(gui.dataMenu,'enable','on');
        set(gui.datasetMenu,'enable','on');
            uimenu(gui.datasetMenu,'Label','Notes','Callback',@gui.editNotes);
            uimenu(gui.datasetMenu,'Label','Source','Callback',@gui.getSource);
            uimenu(gui.datasetMenu,'Label','Displayed Page','Callback',@gui.setPage,'separator','on');
            uimenu(gui.datasetMenu,'Label','Previous Page','Callback',@gui.previousPage,'accelerator','E');
            uimenu(gui.datasetMenu,'Label','Next Page','Callback',@gui.nextPage,'accelerator','D'); 
            %uimenu(gui.datasetMenu,'Label','Update','separator','on','Callback',@gui.update);
            %uimenu(gui.datasetMenu,'Label','Break link','Callback',@gui.breakLinkCallback); 
        set(gui.statisticsMenu,'enable','off');
        set(gui.viewMenu,'enable','on');
        editUIMenu = findobj(gui.viewMenu,'Label','Editable');
        set(editUIMenu,'enable','off');
        
    elseif isempty(gui.data)

        set(gui.dataMenu,'enable','off');
        set(gui.datasetMenu,'enable','off');
        set(gui.statisticsMenu,'enable','off');
        set(gui.viewMenu,'enable','on');
        
        editUIMenu = findobj(gui.viewMenu,'Label','Editable');
        set(editUIMenu,'enable','on');
        
    elseif isDistribution(gui.data)
        
        editUIMenu = findobj(gui.viewMenu,'Label','Editable');
        set(editUIMenu,'enable','on');
        
        set(gui.dataMenu,'enable','on');
        set(gui.datasetMenu,'enable','on');
            uimenu(gui.datasetMenu,'Label','Notes','Callback',@gui.editNotes);
            uimenu(gui.datasetMenu,'Label','Source','Callback',@gui.getSource);
            uimenu(gui.datasetMenu,'Label','Method List','Callback',@gui.getMethodList);
            uimenu(gui.datasetMenu,'Label','Displayed Page','Callback',@gui.setPage,'separator','on');
            uimenu(gui.datasetMenu,'Label','Previous Page','Callback',@gui.previousPage,'accelerator','E');
            uimenu(gui.datasetMenu,'Label','Next Page','Callback',@gui.nextPage,'accelerator','D'); 
            transformMenu = uimenu(gui.datasetMenu,'Label','Transform','separator','on');
                uimenu(transformMenu,'Label','Raw Data','Callback',@gui.getRawData);
                uimenu(transformMenu,'Label','Mean','Callback',@gui.mean);
                uimenu(transformMenu,'Label','Median','Callback',@gui.median);
                uimenu(transformMenu,'Label','Mode','Callback',@gui.mode);
                uimenu(transformMenu,'Label','Variance','Callback',@gui.variance);
                uimenu(transformMenu,'Label','Standard deviation','Callback',@gui.std);
                uimenu(transformMenu,'Label','Skewness','Callback',@gui.skewness);
                uimenu(transformMenu,'Label','Kurtosis','Callback',@gui.kurtosis);
            uimenu(gui.datasetMenu,'Label','Update','separator','on','Callback',@gui.update);
            uimenu(gui.datasetMenu,'Label','Break link','Callback',@gui.breakLinkCallback); 
        set(gui.statisticsMenu,'enable','off');
        set(gui.viewMenu,'enable','off');
        
    else

        set(gui.dataMenu,'enable','on');
        set(gui.datasetMenu,'enable','on');
        set(gui.viewMenu,'enable','on');
        if isa(gui.data,'nb_ts') || isa(gui.data,'nb_data')

            % Create the new dataset menu
            uimenu(gui.datasetMenu,'Label','Notes','Callback',@gui.editNotes);
            uimenu(gui.datasetMenu,'Label','Source','Callback',@gui.getSource);
            uimenu(gui.datasetMenu,'Label','Method List','Callback',@gui.getMethodList);
            uimenu(gui.datasetMenu,'Label','Displayed Page','Callback',@gui.setPage,'separator','on');
            uimenu(gui.datasetMenu,'Label','Previous Page','Callback',@gui.previousPage,'accelerator','E');
            uimenu(gui.datasetMenu,'Label','Next Page','Callback',@gui.nextPage,'accelerator','D'); 
            transformMenu = uimenu(gui.datasetMenu,'Label','Transform','separator','on');
                uimenu(transformMenu,'Label','Raw Data','Callback',@gui.getRawData);
                uimenu(transformMenu,'Label','Log','Callback',@gui.log);
                uimenu(transformMenu,'Label','Exp','Callback',@gui.exp);
                logDiff = uimenu(transformMenu,'Label','Log Diff');
                          uimenu(logDiff,'Label','1','Callback',{@gui.growth,1});
                          uimenu(logDiff,'Label','2','Callback',{@gui.growth,2});
                          uimenu(logDiff,'Label','4','Callback',{@gui.growth,4});
                          uimenu(logDiff,'Label','12','Callback',{@gui.growth,12});
                logDiffPct = uimenu(transformMenu,'Label','Log Diff (%)');
                          uimenu(logDiffPct,'Label','1','Callback',{@gui.pcn,1});
                          uimenu(logDiffPct,'Label','2','Callback',{@gui.pcn,2});
                          uimenu(logDiffPct,'Label','4','Callback',{@gui.pcn,4});
                          uimenu(logDiffPct,'Label','12','Callback',{@gui.pcn,12});
                eGrowth = uimenu(transformMenu,'Label','Growth');
                          uimenu(eGrowth,'Label','1','Callback',{@gui.egrowth,1});
                          uimenu(eGrowth,'Label','2','Callback',{@gui.egrowth,2});
                          uimenu(eGrowth,'Label','4','Callback',{@gui.egrowth,4});
                          uimenu(eGrowth,'Label','12','Callback',{@gui.egrowth,12});
                eGrowthPct = uimenu(transformMenu,'Label','Growth (%)');
                          uimenu(eGrowthPct,'Label','1','Callback',{@gui.epcn,1});
                          uimenu(eGrowthPct,'Label','2','Callback',{@gui.epcn,2});
                          uimenu(eGrowthPct,'Label','4','Callback',{@gui.epcn,4});
                          uimenu(eGrowthPct,'Label','12','Callback',{@gui.epcn,12});
            methodsMenu = uimenu(gui.datasetMenu,'Label','Methods'); 
                createMenu = uimenu(methodsMenu,'Label','Create');
                    uimenu(createMenu,'Label','Variable','Callback',@gui.createVariable);
                    uimenu(createMenu,'Label','Dummy Variable','Callback',@gui.createDummy);
                deleteMenu = uimenu(methodsMenu,'Label','Delete');
                    uimenu(deleteMenu,'Label','Variable(s)','Callback',@gui.deleteVariable);
                reorderMenu = uimenu(methodsMenu,'Label','Re-order');
                    uimenu(reorderMenu,'Label','Variables','Callback',@gui.reorderCallback);
                    uimenu(reorderMenu,'Label','Datasets','Callback',@gui.reorderCallback);
                if isa(gui.data,'nb_ts')
                uimenu(methodsMenu,'Label','Convert Frequency','Callback',@gui.convert);
                uimenu(methodsMenu,'Label','To cross sectional','Callback',@gui.to_nb_csCallback);
                end
                if isa(gui.parent,'nb_GUI')
                uimenu(methodsMenu,'Label','Merge','Callback',@gui.merge);
                end
                rename = uimenu(methodsMenu,'Label','Rename');
                    uimenu(rename,'Label','Variable','Callback',@gui.renameVariable);
                    uimenu(rename,'Label','Pages','Callback',@gui.renamePage);
                uimenu(methodsMenu,'Label','More...','Callback',@gui.selectMethod);
            uimenu(gui.datasetMenu,'Label','Update','separator','on','Callback',@gui.update);
            uimenu(gui.datasetMenu,'Label','Break link','Callback',@gui.breakLinkCallback); 

            set(gui.statisticsMenu,'enable','on');
            uimenu(gui.statisticsMenu,'Label','Summary','Callback',@gui.summaryStatistics);
            uimenu(gui.statisticsMenu,'Label','Covariance','Callback',@gui.covariance);
            uimenu(gui.statisticsMenu,'Label','Correlation','Callback',@gui.correlation);
            uimenu(gui.statisticsMenu,'Label','Principal Component','Callback',@gui.pca);
            if isa(gui.data,'nb_ts')
            uimenu(gui.statisticsMenu,'Label','Unit Root','Callback',@gui.unitRoot);
            cointegrationMenu = uimenu(gui.statisticsMenu,'Label','Cointegration Tests');
                uimenu(cointegrationMenu,'Label','Johansen Test','Callback',{@gui.cointegration,'johansen'});
                uimenu(cointegrationMenu,'Label','Engle-Granger Test','Callback',{@gui.cointegration,'engle-granger'});
            uimenu(gui.statisticsMenu,'Label','Jarque-Bera Test','Callback',@gui.jbTest);
            end  
            uimenu(gui.statisticsMenu,'Label','Autocorrelation','Callback',@gui.autocorr);

        elseif isa(gui.data,'nb_cs')

            uimenu(gui.datasetMenu,'Label','Notes','Callback',@gui.editNotes);
            uimenu(gui.datasetMenu,'Label','Source','Callback',@gui.getSource);
            uimenu(gui.datasetMenu,'Label','Method List','Callback',@gui.getMethodList);
            uimenu(gui.datasetMenu,'Label','Displayed Page','Callback',@gui.setPage,'separator','on');
            uimenu(gui.datasetMenu,'Label','Previous Page','Callback',@gui.previousPage,'accelerator','Q');
            uimenu(gui.datasetMenu,'Label','Next Page','Callback',@gui.nextPage,'accelerator','A'); 
            transformMenu = uimenu(gui.datasetMenu,'Label','Transform','separator','on');
                uimenu(transformMenu,'Label','Raw Data','Callback',@gui.getRawData);
                uimenu(transformMenu,'Label','Log','Callback',@gui.log);
                uimenu(transformMenu,'Label','Exp','Callback',@gui.exp);
            methodsMenu = uimenu(gui.datasetMenu,'Label','Methods');
                createMenu = uimenu(methodsMenu,'Label','Create');
                    uimenu(createMenu,'Label','Variable','Callback',@gui.createVariable);
                    uimenu(createMenu,'Label','Type','Callback',@gui.createType);
                %uimenu(methodsMenu,'Label','Add Dummy Variable','Callback','');
                deleteMenu = uimenu(methodsMenu,'Label','Delete');
                    uimenu(deleteMenu,'Label','Variable(s)','Callback',@gui.deleteVariable);
                    uimenu(deleteMenu,'Label','Type(s)','Callback',@gui.deleteType);
                reorderMenu = uimenu(methodsMenu,'Label','Re-order');
                    uimenu(reorderMenu,'Label','Variables','Callback',@gui.reorderCallback);
                    uimenu(reorderMenu,'Label','Types','Callback',@gui.reorderCallback);
                    uimenu(reorderMenu,'Label','Datasets','Callback',@gui.reorderCallback);
                if isa(gui.parent,'nb_GUI')
                uimenu(methodsMenu,'Label','Merge','Callback',@gui.merge);
                end
                uimenu(methodsMenu,'Label','More...','Callback',@gui.selectMethod);
            uimenu(gui.datasetMenu,'Label','Update','separator','on','Callback',@gui.update);
            uimenu(gui.datasetMenu,'Label','Break link','Callback',@gui.breakLinkCallback);
            
            set(gui.statisticsMenu,'enable','on');
            uimenu(gui.statisticsMenu,'Label','Summary','Callback',@gui.summaryStatistics);
            uimenu(gui.statisticsMenu,'Label','Covariance','Callback',@gui.covariance);
            uimenu(gui.statisticsMenu,'Label','Correlation','Callback',@gui.correlation);
          
        else % nb_cell
            
            uimenu(gui.datasetMenu,'Label','Notes','Callback',@gui.editNotes);
            uimenu(gui.datasetMenu,'Label','Source','Callback',@gui.getSource);
            uimenu(gui.datasetMenu,'Label','Method List','Callback',@gui.getMethodList);
            uimenu(gui.datasetMenu,'Label','Displayed Page','Callback',@gui.setPage,'separator','on');
            uimenu(gui.datasetMenu,'Label','Previous Page','Callback',@gui.previousPage,'accelerator','Q');
            uimenu(gui.datasetMenu,'Label','Next Page','Callback',@gui.nextPage,'accelerator','A'); 
            transformMenu = uimenu(gui.datasetMenu,'Label','Transform','separator','on');
                uimenu(transformMenu,'Label','Raw Data','Callback',@gui.getRawData);
                uimenu(transformMenu,'Label','Log','Callback',@gui.log);
                uimenu(transformMenu,'Label','Exp','Callback',@gui.exp);
            methodsMenu = uimenu(gui.datasetMenu,'Label','Methods');
                reorderMenu = uimenu(methodsMenu,'Label','Re-order');
                    uimenu(reorderMenu,'Label','Datasets','Callback',@gui.reorderCallback);
                uimenu(methodsMenu,'Label','More...','Callback',@gui.selectMethod);
            uimenu(gui.datasetMenu,'Label','Update','separator','on','Callback',@gui.update);
            uimenu(gui.datasetMenu,'Label','Break link','Callback',@gui.breakLinkCallback);
            set(gui.statisticsMenu,'enable','off');
            
        end

    end

end
