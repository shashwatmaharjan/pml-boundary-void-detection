clc; clear all;

%% Define directories
% Get the current directory
current_directory = pwd;

% Define directory of the data
raw_data_directory = fullfile(current_directory, '..', '..', 'data', 'raw');

% Define directory of the assembled data
assembled_data_directory = fullfile(current_directory, '..', '..', 'data', 'assembled');

% List all the folders in the raw data directory
raw_data_folders = dir(raw_data_directory);

% Remove the first two folders (.) and (..)
raw_data_folders = raw_data_folders(3:end);
raw_data_folders = {raw_data_folders.name};

% Rename raw_data_folders to void_folders
void_folders = raw_data_folders;

%% Data Stack
% Loop through all the folders
for n_void = 1:length(void_folders)

    % Print which sample is being processed
    fprintf('Retrieving void %d data...\n', n_void-1);

    % Define the folder name and full path
    folder_name = void_folders{n_void};
    folder_directory = fullfile(raw_data_directory, folder_name);

    % List all the folders in the folder directory
    all_data_files = dir(folder_directory);

    % Remove the first two folders (.) and (..)
    all_data_files = all_data_files(3:end);
    all_data_files = {all_data_files.name};

    % Get the number of data files
    % Dividing by 2 because there are two files for a sample: displacement and void
    num_data_files = length(all_data_files)/2;

    % Loop through all the data files
    for n_file = 1:num_data_files

        % If first sample
        if n_file == 1

            % Load the displacement data
            displacement_data = load(fullfile(folder_directory, strcat('Signal_data_', int2str(n_file), '.mat')));
            displacement_data = displacement_data.(['Signal_data_', int2str(n_file)]);

            % Convert the data from cell to matrix
            displacement_data = cat(3, displacement_data{:});

            % Load the void data
            void_data = load(fullfile(folder_directory, strcat('Crack_data_', int2str(n_file), '.mat')));
            void_data = void_data.(['Crack_data_yes_no_1']);

            % If any other sample, stack on top of the data
        else

            % Load the displacement data
            additional_displacement_data = load(fullfile(folder_directory, strcat('Signal_data_', int2str(n_file), '.mat')));
            additional_displacement_data = additional_displacement_data.(['Signal_data_', int2str(n_file)]);

            % Convert the data from cell to matrix
            additional_displacement_data = cat(3, additional_displacement_data{:});

            % Stack the data on the third axes
            displacement_data = cat(3, displacement_data, additional_displacement_data);

            % Load the void data
            additional_void_data = load(fullfile(folder_directory, strcat('Crack_data_', int2str(n_file), '.mat')));
            additional_void_data = additional_void_data.(['Crack_data_yes_no_1']);

            % Stack the data on the first axes
            void_data = cat(1, void_data, additional_void_data);

        end

    end

    % Take every third timestep
    displacement_data = displacement_data(:, 1:3:end, :);

    %% Reshape
    % Reshape the data such that the shape is: [n_samples, n_time_steps, n_sensors]
    displacement_data = permute(displacement_data, [3, 2, 1]);

    % Save the displacement and void data as a .mat file.
    save(fullfile(assembled_data_directory, strcat('void_', int2str(n_void-1), '_displacement_data.mat')), 'displacement_data');
    save(fullfile(assembled_data_directory, strcat('void_', int2str(n_void-1), '_void_data.mat')), 'void_data');

end
