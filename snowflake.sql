-- Creating an Integration object to connect with s3
CREATE OR REPLACE STORAGE INTEGRATION aws_sf_data 
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN='arn:aws:iam::203918863031:role/snowflake-s3'
STORAGE_ALLOWED_LOCATIONS=('s3://customer-churn-data1/');

desc INTEGRATION aws_sf_data;



create  or replace database customer;
use database customer;
create schema customer_schema;

use schema customer_schema;

CREATE OR REPLACE TABLE churn_data (
    customerID VARCHAR,
    gender VARCHAR,
    SeniorCitizen INT,
    Partner VARCHAR,
    Dependents VARCHAR,
    tenure INT,
    PhoneService VARCHAR,
    MultipleLines VARCHAR,
    InternetService VARCHAR,
    OnlineSecurity VARCHAR,
    OnlineBackup VARCHAR,
    DeviceProtection VARCHAR,
    TechSupport VARCHAR,
    StreamingTV VARCHAR,
    StreamingMovies VARCHAR,
    Contract VARCHAR,
    PaperlessBilling VARCHAR,
    PaymentMethod VARCHAR,
    MonthlyCharges FLOAT,
    TotalCharges VARCHAR,  
    Churn VARCHAR
);


select * from churn_data;


CREATE FILE FORMAT csv_load_format1
    TYPE = 'CSV' 
    COMPRESSION = 'AUTO' 
    FIELD_DELIMITER = ',' 
    RECORD_DELIMITER = '\n' 
    SKIP_HEADER =1 
    FIELD_OPTIONALLY_ENCLOSED_BY = '\042' 
    TRIM_SPACE = FALSE 
    ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
    ESCAPE = 'NONE' 
    ESCAPE_UNENCLOSED_FIELD = '\134' 
    DATE_FORMAT = 'AUTO' 
    TIMESTAMP_FORMAT = 'AUTO';

CREATE OR REPLACE FILE FORMAT my_csv_format
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  FIELD_DELIMITER = ','
  NULL_IF = ('NULL', 'null');

create or replace stage customer_stg
storage_integration = aws_sf_data
url = 's3://customer-churn-data1/Telco-Customer-Churn.csv'
file_format = my_csv_format;

LIST @customer_stg;


copy into churn_data from @customer_stg ON_ERROR = continue;

show pipes;

select * from churn_data;



CREATE OR REPLACE TABLE new_data_table (
    customerID VARCHAR,
    gender VARCHAR,
    SeniorCitizen INT,
    Partner VARCHAR,
    Dependents VARCHAR,
    tenure INT,
    PhoneService VARCHAR,
    MultipleLines VARCHAR,
    InternetService VARCHAR,
    OnlineSecurity VARCHAR,
    OnlineBackup VARCHAR,
    DeviceProtection VARCHAR,
    TechSupport VARCHAR,
    StreamingTV VARCHAR,
    StreamingMovies VARCHAR,
    Contract VARCHAR,
    PaperlessBilling VARCHAR,
    PaymentMethod VARCHAR,
    MonthlyCharges FLOAT,
    TotalCharges VARCHAR  
);

CREATE OR REPLACE TABLE predictions_results (
    customerID VARCHAR,
    PREDICTION VARCHAR  -- This will store the predicted churn status ('Yes' or 'No')
);


INSERT INTO new_data_table (customerID, gender, SeniorCitizen, Partner, Dependents, 
tenure, PhoneService, MultipleLines, InternetService, OnlineSecurity, 
OnlineBackup, DeviceProtection, TechSupport, StreamingTV, StreamingMovies, 
Contract, PaperlessBilling, PaymentMethod, MonthlyCharges, TotalCharges)
VALUES 
('C001', 'Female', 0, 'Yes', 'No', 24, 'Yes', 'No', 'Fiber optic', 'No', 
'Yes', 'Yes', 'No', 'Yes', 'No', 'Month-to-month', 'Yes', 'Credit card (automatic)', 
75.00, '1800.50');

select * from new_data_table;

select * from predictions_results;

