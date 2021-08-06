function obj = test()
    variables = {'QSA_CP','QSA_PCPIJAE','QSA_YMN','QSA_URR'};
    data = nb_ts('histdata.db', '', '1990Q1', variables);

    transformations = {
        'QSA_DPQ_YMN',        'pcn(QSA_YMN)',    {{'constant',0}},'GDP growth'
        'QSA_DPQ_YMN_GAP',    'pcn(QSA_YMN)',    {'avg'}, 'GDP growth gap'
        'QSA_DPQ_PCPIJAE_GAP','pcn(QSA_PCPIJAE)',{'avg'}, 'CPI-ATE inflation gap'
        'QSA_DPQ_CP_GAP',     'pcn(QSA_CP)',     {'avg'}, 'Consumption growth gap'
        'QSA_URR_GAP',        'QSA_URR',         {'avg'}, 'Unemployment gap'
    };

    reporting = {
        'QSA_DPQ_YMN',  'QSA_DPQ_YMN_GAP',        'GDP growth'
    };

    obj = nb_model_selection_group({}, ...
        'data', data, ...
        'varOfInterest', 'QSA_DPQ_YMN', ...
        'modelVarOfInterest', 'QSA_DPQ_YMN_GAP', ...
        'variables', {'QSA_DPQ_YMN_GAP', 'QSA_DPQ_PCPIJAE_GAP'}, ...
        'reporting', reporting);
    
    obj = createVariables(obj, transformations);

    obj = modelSelection(obj);
end
