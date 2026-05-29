function model = save_load_model(action, model, filename)
%SAVE_LOAD_MODEL Save or load a trained model
%   save_load_model('save', model, filename)
%   save_load_model('load', [], filename) -> returns model

if strcmp(action, 'save')
    save(filename, 'model');
elseif strcmp(action, 'load')
    tmp = load(filename, 'model');
    model = tmp.model;
    disp('Model loaded');
else
    error('Unknown action. Use "save" or "load"');
end

end
