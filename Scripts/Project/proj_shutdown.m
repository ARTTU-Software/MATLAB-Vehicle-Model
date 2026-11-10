modelName = "analytical_models";
if bdIsLoaded(modelName)
    close_system(modelName, bdIsDirty(modelName));
end

clear
clc

% MATLAB removes the folders listed in matlab.toml when the project closes.
