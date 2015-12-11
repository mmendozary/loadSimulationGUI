classdef slexVarSizeMATLABSystemGetDBIDsSysObj < matlab.System & matlab.system.mixin.Propagates
%slexVarSizeMATLABSystemGetDBIDsSysObj Find units that match the given pattern in their names.
%     The pattern is specified in the block dialog. Both outputs 
%     are variable-sized vectors.
%

% Copyright 2013 The MathWorks, Inc.

properties (Nontunable)
    % db_name Database
    db_name = 'WaterHeaters';
    % db_username user
    db_username = 'sw_waterheaters';
    % Condition Search pattern
    Condition = ['%' datestr(now,'yyyymmdd') '%'];
    % id_column_name UnitID
    id_column_name = 'WaterHeaterID';
    % name_column_name Unit Name sored
    name_column_name = 'WaterHeaterName';
    % name_column_name Unit Name sored
    power_column_name = 'InputPower';
    % table_name Unit table Name 
    table_name = 'WaterHeaters';
end

properties
   % db_password password
   db_password ='unb.sql.2015';
   % N maximum number of units
   N = 100;
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
    unitIDs = 0;
end

  methods
    function this = slexVarSizeMATLABSystemGetDBIDsSysObj(varargin)
        setProperties(this, nargin, varargin{:});
    end
  end
  
  methods(Static, Access = protected)
  %'slexVarSizeMATLABSystemGetDBIDsSysObj', ...    
      function header = getHeaderImpl
          header = matlab.system.display.Header(...
              'Title', 'Load Simulation access parameters', ...
              'Text',  'Find units that match the given pattern in their names');
      end
      
      function groups = getPropertyGroupsImpl
          firstGroup = matlab.system.display.SectionGroup(...
              'Title', 'Select', ...
              'PropertyList', {'Condition', 'N'});
            
          secondGroup = matlab.system.display.SectionGroup(...
              'Title', 'Database', ...
              'PropertyList', {'db_name', 'db_username', 'db_password'});
            
          groups = [firstGroup, secondGroup];
      end
  
      function simMode = getSimulateUsingImpl(~)
          simMode = 'Interpreted execution';
      end
      
      function flag = showSimulateUsingImpl
          flag = false;
      end

  end
    
  methods(Access=protected)

      function setupImpl(obj, ~, ~)
          login.username = obj.db_username;
          login.password = obj.db_password;
          
          
          conn = open_sql_conn(obj.db_name, login);
          
          if (isempty(conn))
              error('Database connection error.');
          end
          
          %% TO DO: too particular. More general code should be implemented here
          if (strcmpi('WaterHeaters',obj.db_name))
              obj.table_name = 'WaterHeaters';
              obj.id_column_name = 'WaterHeaterID';
              obj.name_column_name = 'WaterHeaterName';
              obj.power_column_name = 'InputPower';
          end
          
          if (strcmpi('heatingUnits',obj.db_name))
              obj.table_name = 'ETSs';
              obj.id_column_name = 'ETSID';
              obj.name_column_name = 'ETSName';
              obj.power_column_name = 'ETSPower';
          end
          
          if (strcmpi('powerMeters',obj.db_name))
              obj.table_name = 'Meters';
              obj.id_column_name = 'MeterID';
              obj.name_column_name = 'MeterName';
              obj.power_column_name = 'Power_P1';
          end
          
%           keyboard
          %%
          obj.unitIDs = fetch(conn, [' SELECT TOP ' num2str(obj.N,'%d '), ' ' obj.id_column_name...
              ,' FROM ', obj.table_name, ' WHERE ', obj.name_column_name, ' LIKE ', '''' obj.Condition '''' ]);
          %Close database connection.
          close(conn);
          
          if (isempty(obj.unitIDs))
              error('No devices matched search criterium.');
          end
      end
      
      function [values, ids] = stepImpl(obj)
%           keyboard
tStart = tic;
          ids = double(obj.unitIDs);
          if (~isempty(ids))
              nIDs = length(ids);
              
              % allocate space for samples
              values = zeros(size(ids));
              
              login.username = obj.db_username;
              login.password = obj.db_password;
              
              % open database connection
              conn = open_sql_conn(obj.db_name, login);
              if (isempty(conn))
                  error('Database connection error.');
              end

              queryParams.varNames = {obj.power_column_name};
              
              % TO DO: read only the sample generated during the last
              % sample period
              queryParams.startDate = floor(now);
              % retrieve values from database
%               keyboard
              for i =1:nIDs
                   queryParams.deviceId = ids(i);
                   data  = db_get_device_readings( conn, queryParams );
                   values(i) = data.(obj.power_column_name)(end);
              end
              close (conn);
          else
              ids = -1; % negative values indicate missing values
              values = -1; % negative values indicate missing values
          end
 tElapsed = toc(tStart);
 disp(tElapsed);
      end
      
      function num = getNumInputsImpl(~)
          num = 0;
      end
    
      function num = getNumOutputsImpl(~)
          num = 2;
      end

      function icon = getIconImpl(~)
          icon = 'NoName';
      end
        
      function [name1, name2] = getOutputNamesImpl(~)
          name1 = 'Output';
          name2 = 'unitIDs';
      end
      
      function [sz1, sz2] = getOutputSizeImpl(obj)
          % Maximum length of linear indices and element vector is the
          % number of elements in the input
          sz1 = obj.N;
          sz2 = sz1;
      end
      
      function [fz1, fz2] = isOutputFixedSizeImpl(~)
          %Both outputs are always variable-sized
          fz1 = false;
          fz2 = false;
      end
      
      function [dt1, dt2] = getOutputDataTypeImpl(~)
          dt1 = 'double'; %Linear indices are always double values
          dt2 = 'double';
      end
      
      function [cp1, cp2] = isOutputComplexImpl(~)
          cp1 = false; %unit ids are always real values
          cp2 = false; % power values are always real
      end
      
  end
  
end
