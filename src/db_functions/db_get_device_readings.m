function readings  = db_get_device_readings( varargin )
%DB_GET_DEVICE_READINGS Retrieves powermeter data from a MSSQL database
% called as db_get_powermeter_readings(  SQLConnection, queryParams)
% where queryParams fields include 
%  deviceId  - (required field) An integer number specifying device ID number 
%           See also DB_GET_DEVICES
%
%  startDate - (optional) start datetime . Format 'yyyyy-mm-dd HH:MM'
%  endDate -   (optional) final datetime . Format 'yyyyy-mm-dd HH:MM'
%  varNames -  (optional) columns to be retrieved from Table
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
%  queryParams.startDate = '2015-10-01 12:0:0';
%  queryParams.endDate = '2015-10-16 18:0:0';
%  data  = DB_GET_DEVICE_READINGS( conn, queryParams );
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
    readings  = []; % ensure output argument is assigned if an error occurs
    
    if isfield(queryParams, 'deviceId')
       deviceId = queryParams.deviceId; 
    else 
        err = MException('DB:connectionError', 'Device Id required');
        throw(err);  
    end
    
    if isfield(queryParams, 'varNames');
        varNames = strjoin(queryParams.varNames(:)',', ');
    else
        varNames = '*';
    end

    sqlQuery = fcn_getReadingsQuery( conn  );
    sqlQuery = sprintf(sqlQuery, varNames, deviceId);

    if isfield(queryParams, 'startDate');
        startDate = datestr(queryParams.startDate, 31) ;
        sqlQuery = strcat(  sqlQuery , ' and ' , ' dt >=  ', '''',  startDate, '''');
    end
    
    if isfield(queryParams, 'endDate');
        endDate = datestr(queryParams.endDate, 31);
        sqlQuery = strcat( sqlQuery , ' and ' ,  ' dt <= ', '''',  endDate, '''');
    end
    
    % ensure time ordering of the samples (sometimes they are out of order)
    sqlQuery = strcat( sqlQuery , ' ORDER BY ',	' dt ', ' ASC ');
    
    % fetch data
    readings = fetch(conn, sqlQuery);
    
catch e
    e.message
    e.stack
end

if connCreated   % close the connection if it was created.
    close(conn);
end

end

%% Utility functions
function sqlQuery = fcn_getReadingsQuery( conn  ) 

% sqlQuery = 'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES ';
% sqlQuery = 'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE ''%READING%''';
sqlQuery = [...
    'SELECT TABLE_CATALOG'...
    ', TABLE_SCHEMA'...
    ', TABLE_NAME'...
    ', COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE'...
    ' WHERE TABLE_NAME LIKE ''%READING%'''...
    ' AND CONSTRAINT_NAME LIKE ''%FK__%'' '];
try
    db_specs = fetch(conn, sqlQuery);
    sqlQuery = sprintf( ' SELECT %%s FROM [%s].[%s] WHERE %s = %%d'...
        , db_specs.TABLE_SCHEMA{1}, db_specs.TABLE_NAME{1}, db_specs.COLUMN_NAME{1} );
catch e
    e.message
    e.stack
end


end


