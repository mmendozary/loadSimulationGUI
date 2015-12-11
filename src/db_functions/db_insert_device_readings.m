function count = db_insert_device_readings( varargin )
%DB_INSERT_DEVICE_READINGS Inserts data to table of readings in a MSSQL
%database. Data are supposed to be readings from a sensor device.
%
% called as DB_INSERT_DEVICE_READINGS(  SQLConnection, readings )
% where readings is a structure which fields include 
%  deviceId  - (required field) An integer number specifying device ID
%  number  as it apears in the database
%           See also DB_GET_DEVICES to know available device IDs if it is
%           not known by some other means
%  varNames -  (required field) columns to be altered in the Table of
%              readings
%  varValues - (required field) corresponding varName values that will be
%              inserted in teh database
%  
% returns:
%  number of rows inserted in the database
% Example 
%  Make connection to database.  Note that the password has been omitted.
%  Using JDBC driver.
%
%  login.username = 'username';
%  login.password = 'password';
%  db_name = 'powerMeters'; 
%  conn = open_sql_conn( db_name, login );
%
%  readings.deviceId = 1;
%  readings.varNames = {'dt','Power_P1','Power_P2','Power_P3','Power_PSum'};

%  % two rows of values:
%  readings.varValues = {[now-1; now], [3.5;4.6], [0;0], [0;0], [0;0] };
%
%  count  = DB_INSERT_DEVICE_READINGS(  SQLConnection, readings );
%


% Julian Cardenas 2015

narginchk(2,3); % two or three function parameters required

connCreated = false; % assuming db connection was done outside this function
if (nargin == 3)
    db_name = varargin{1};
    login = varargin{2};
    queryParams = varargin{3}; 
    
    %open connection
    conn = open_sql_conn( db_name, login );
    connCreated = true;
elseif nargin == 2
    conn = varargin{1};
    queryParams = varargin{2}; 
end

if ~isconnection(conn)
    err = MException('DB:connectionError', 'Invalid db connection.');
    throw(err);
end

dbases = {'powerMeters';'HeatingUnits';'WaterHeaters'};
dbasedbIDs = strmatch(conn.Instance, dbases);
if isempty(dbasedbIDs)
    err = MException('DB:invalidDatabase', 'Database not known.');
    throw(err);
end

try
    
    count = db_insert_readings( conn,  queryParams );
    
catch e
    e.message
    e.stack
end

if connCreated   % close the connection if it was created.
    close(conn);
end

end

function count = db_insert_readings( varargin )
%DB_INSERT_POWERMETER_READINGS Inserts powermeter data to a MSSQL database
% called as DB_INSERT_POWERMETER_READINGS(  SQLConnection, queryParams)
% where queryParams fields include 
%  deviceId  - (required field) An integer number specifying meter ID number 
%           See also DB_GET_METERS
%  varNames -  (required field) columns to be altered in the Table
%  varValues - (required field) corresponding values that will be inserted
%  
% returns:
%  number of rows inserted in the database
% Example 
%  Make connection to database.  Note that the password has been omitted.
%  Using JDBC driver.
%
%  conn = database('powerMeters', 'sql_user', '', ...
%     'Vendor', 'Microsoft SQL Server', 'AuthType', 'Server', ...
%     'Server', 'livingLabLM.ad.unb.ca', ...
%     'PortNumber', 1433);
%
%  queryParams.deviceId = 1;
%  queryParams.varNames = {'dt', 'Power_P1','Power_P2','Power_P3','Power_PSum'};
%  %two rows of values:
%  queryParams.varValues = {[now-1; now], [3.5;4.6], [0;0], [0;0], [0;0] };
%
%  count  = DB_INSERT_POWERMETER_READINGS( conn, queryParams );
%


% Julian Cardenas 2015

narginchk(1,2); % one or two function parameters required

connCreated = false; % assuming db connection was done outside this function
if nargin == 2
    conn = varargin{1};
    queryParams = varargin{2}; 
    if ~isconnection(conn)
        err = MException('DB:connectionError', 'Invalid db connection.');
        throw(err);    
    end
elseif (nargin == 1)
    if ( ~isstruct( varargin{1} ) && isconnection(varargin{1}) )
        err = MException('DB:connectionError', 'Query parameters required ');
        throw(err);    
    else 
        queryParams = varargin{1};
        conn = get_powermeter_sql_conn();
        connCreated = true;
    end
end

try
    count  = 0; % ensure output argument is assigned if an error occurs
    
    if isfield(queryParams, 'deviceId')
       deviceId = queryParams.deviceId; 
    else 
        err = MException('DB:connectionError', 'Meter Id required');
        throw(err);  
    end
    
    if (~isfield(queryParams, 'varNames'))
        err = MException('DB:connectionError', 'varNames required');
        throw(err);  
    end
    if (~isfield(queryParams, 'varValues'))
        err = MException('DB:connectionError', 'varValues required');
        throw(err);  
    end

    db_specs = fcn_get_db_specs( conn  );

    varNames = strjoin(queryParams.varNames(:)',', ');
    nvars = length(queryParams.varNames);
    
    varValues = queryParams.varValues;
    if ( nvars ~= size(varValues,2))
        %mismatch between number of variables and corresponding values
        err = MException('DB:nsertionError', 'Column and values should be the same');
        throw(err);  
    end
    nobs = size(varValues{1}, 1); % # of observations (rows)
    

    
    
    sqlQuery = sprintf([...
        'SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS ' ...
        ' WHERE TABLE_SCHEMA = ''%s''  ' ...
        ' AND TABLE_NAME = ''%s'' '], db_specs.TABLE_SCHEMA{1}, db_specs.TABLE_NAME{1});
    for i=1:nvars
        r = fetch(conn, sprintf('%s AND COLUMN_NAME = ''%s''  ', sqlQuery, queryParams.varNames{i}));
        
        if (strcmp(r.DATA_TYPE,'datetime'))
            varValues (:,i) = { strcat('''', datestr(varValues{i}, 31), '''')};
        else
            varValues (:,i) = {num2str(varValues{i})};
        end
        
    end
     
    sqlQuery = sprintf( ' INSERT INTO [%s].[%s] ( %s, %s )'...
        , db_specs.TABLE_SCHEMA{1}, db_specs.TABLE_NAME{1}, db_specs.COLUMN_NAME{1}, varNames );
    
    for i=1:nobs
        strRowValues = num2str(deviceId);
        for j=1:nvars
            strColValues =  cellstr(varValues{j});
            strRowValues = strcat(strRowValues, ',', strColValues(i));
        end
        thisQuery = sprintf('%s VALUES (%s) ', sqlQuery, strRowValues{1});
        
        % insert data
        curs = exec(conn, thisQuery);
        if (~isempty(curs.Message))
            error(curs.Message);
        end
        count = count + 1;
    end
    
catch e
    e.message
    e.stack
end

if connCreated   % close the connection if it was created.
    close(conn);
end

end



%% Utility functions
function db_specs = fcn_get_db_specs( conn  ) 

sqlQuery = [...
    'SELECT TABLE_CATALOG'...
    ', TABLE_SCHEMA'...
    ', TABLE_NAME'...
    ', COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE'...
    ' WHERE TABLE_NAME LIKE ''%READING%'''...
    ' AND CONSTRAINT_NAME LIKE ''%FK__%'' '];
    
db_specs = fetch(conn, sqlQuery);

end
