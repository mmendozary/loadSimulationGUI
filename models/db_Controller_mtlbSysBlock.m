classdef db_Controller_mtlbSysBlock < matlab.System & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    % db_Controller_mtlbSysBlock Basic Controller to show control
    % performance
    %
    % NOTE: When renaming the class name Untitled2, the file name
    % and constructor name must be updated to use the class name.
    %
    % This template includes most, but not all, possible properties, attributes,
    % and methods that you can implement for a System object in Simulink.

    properties
        % Public, tunable properties.
    end

    properties (Nontunable)
        % db_name Database
        db_name = 'WaterHeaters';
        % db_username user
        db_username = 'sw_waterheaters';

        % unit_table_name Unit table Name
        unit_table_name = 'WaterHeaters';
        % id_column_name UnitID
        id_column_name = 'WaterHeaterID';
        % name_column_name Unit Name sored
        statusID_column_name = 'WaterHeaterStatusID';
        
        % status_table_name Unit table Name
        status_table_name = 'WaterHeaterStatus';
        % status_id_column_name Unit table Name
        status_id_column_name = 'WaterHeaterID';
        % command_column_name Unit Name sored
        command_column_name = 'commandStatus';
    end

    properties
        % db_password password
        db_password ='unb.sql.2015';
    end

    properties (Constant, Hidden)
        db_nameSet = matlab.system.StringSet({...
            'WaterHeaters', ...
            'HeatingUnits', ...
            'powerMeters'});
        db_usernameSet = matlab.system.StringSet({...
            'sw_waterheaters', ...
            'sw_ETS', ...
            'sw_powermeters'});
        db_passwordSet = matlab.system.StringSet({...
            'unb.sql.2015', ...
            'sql.2015', ...
            'unb.2015'});
    end
    
    properties (Access = private)
        % Pre-computed constants.
    end

    properties (DiscreteState)
    end

    methods
        % Constructor
        function obj = db_Controller_mtlbSysBlock(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods (Access = protected)
        %% Common functions
        function setupImpl(obj,u)
            % Implement tasks that need to be performed only once,
            % such as pre-computed constants.
        end

        function ctrlOut = stepImpl(obj,aggIn, unitIDs)
            % Implement algorithm. Calculate y as a function of
            % input u and discrete states.
            keyboard
            if ~isempty(unitIDs)
                
                ids = double(unitIDs);
                nIds = numel(ids);
                
                % generate the control signals
                % TO DO: a proper algorithm should be implemented based on
                % the forecasts. A times shoudl be setup to determine when
                % the lodas are to be turned off or tuned on. The algorithm
                % analyzes future events and hence turning on and off
                % should be scheduled. 
                command_options = [0;1;-1];
                control_signal = command_options(randi([1,3],nIds,1));

                % access to the database
                login.username = obj.db_username;
                login.password = obj.db_password;
                
                
                conn = open_sql_conn(obj.db_name, login);
                
                if (isempty(conn))
                    error('Database connection error.');
                end
                
                %% TO DO: too particular. More general code should be implemented here
                if (strcmpi('WaterHeaters',obj.db_name))
                    obj.unit_table_name = 'WaterHeaters';
                    obj.id_column_name = 'WaterHeaterID';
                    obj.statusID_column_name = 'WaterHeaterStatusID';
        
                    obj.status_table_name = 'WaterHeaterStatus';
                    obj.status_id_column_name = 'statusID';
                    obj.command_column_name = 'commandStatus';
                end
                
                if (strcmpi('heatingUnits',obj.db_name))
                    obj.unit_table_name = 'ETSs';
                    obj.id_column_name = 'ETSID';
                    obj.statusID_column_name = 'ETSStatusID';
        
                    obj.status_table_name = 'ETSStatus';
                    obj.status_id_column_name = 'statusID';
                    obj.command_column_name = 'commandStatus';

                end
                
                if (strcmpi('powerMeters',obj.db_name))
                    error('power meters can not be controlled')
                end
                %%
               
                for i =1:nIds
                    unitID = ids(i);
                    
                    % select statusID row
                    sqlQuery = sprintf('SELECT %s FROM %s WHERE %s = %d', ...
                        obj.statusID_column_name, obj.unit_table_name, obj.id_column_name, unitID);
                    statusID = fetch(conn, sqlQuery);
                    
                    % modify command
                    whereclause = sprintf('%s = %d', obj.status_id_column_name, statusID);
                    update(conn, obj.status_table_name, obj.command_column_name, control_signal(i), whereclause);
                end
                close (conn);
            end
            ctrlOut = aggIn;
        end

        function resetImpl(obj)
            % Initialize discrete-state properties.
        end

        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Save private, protected, or state properties in a
            % structure s. This is necessary to support Simulink 
            % features, such as SimState.
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Read private, protected, or state properties from
            % the structure s and assign it to the object obj.
        end

        %% Simulink functions
        function z = getDiscreteStateImpl(obj)
            % Return structure of states with field names as
            % DiscreteState properties.
            z = struct([]);
        end

        function flag = isInputSizeLockedImpl(obj,index)
            % Set true when the input size is allowed to change while the
            % system is running.
            flag = false;
        end

        function sz = getOutputSizeImpl(obj)
            % Implement if input size does not match with output size.
            sz = propagatedInputSize(obj,2);
        end
        
        function dt = getOutputDataTypeImpl(obj)
            dt = propagatedInputDataType(obj,2);
        end
        
        function [cp1, cp2] = isOutputComplexImpl(~)
            cp1 = false; %unit ids are always real values
            cp2 = false; % power values are always real
        end
        
        function icon = getIconImpl(obj)
            % Define a string as the icon for the System block in Simulink.
            icon = 'Controller';
        end
        
        function [fz1] = isOutputFixedSizeImpl(~)
            %Both outputs are always variable-sized
            fz1 = false;
        end
    end

    methods(Static, Access = protected)
        %% Simulink customization functions
      function header = getHeaderImpl
          header = matlab.system.display.Header(...
              mfilename('class'),...
              'Title', 'Controller Parameters', ...
              'Text',  'Basic Controller to show control performance');
      end

       function group = getPropertyGroupsImpl(obj)
            % Define section for properties in System block dialog box.
            group = matlab.system.display.Section('Title', 'Database', ...
              'PropertyList', {'db_name', 'db_username', 'db_password'});
        end
        
        function simMode = getSimulateUsingImpl(~)
            simMode = 'Interpreted execution';
        end

        function flag = showSimulateUsingImpl
            flag = false;
        end
        
    end
end
