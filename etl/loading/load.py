import pandas as pd
import awswrangler as wr
import os
import traceback
import sys
current_path = os.getcwd()
sys.path.append(f"{os.path.dirname(current_path)}")
from utils import logger
import boto3


class Loading:
    def __init__(self):
        self.logger = logger()

    def convert_to_csv(self,
                       customer_df: pd.core.frame.DataFrame,
                       loan_df: pd.core.frame.DataFrame,
                       fact_table: pd.core.frame.DataFrame
                       ) -> None:

        self.logger.info("converting dataframes to csv")
        customer_df.to_csv("/tmp/customer_df.csv")
        loan_df.to_csv("/tmp/loan_df.csv")
        fact_table.to_csv("/tmp/fact_table.csv")
        self.logger.info("Successfully converted data to csv")

    def write_to_s3(self, bucket_name: str) -> None:
        try:
            s3_client = boto3.client("s3")
            self.logger.info("Uploading data to s3")
            s3_client.upload_file("/tmp/customer_df.csv", bucket_name,
                                  "customer_data/customer_df.csv")

            s3_client.upload_file("/tmp/loan_df.csv", bucket_name,
                                  "loan_data/loan_df.csv")

            s3_client.upload_file("/tmp/fact_table.csv", bucket_name,
                                  "fact_table/fact_table.csv")

            self.logger.info("Successfully written data to s3")

        except Exception as err:
            self.logger.error(f"Error loading data to s3. Msg:{err}")
            traceback.format_exc()

    def load_redshift(self, connection: str, bucket: str,
                      redshift_iam: str, db: str) -> None:
        conn = wr.redshift.connect(connection=connection,
                                   ssl=False)
        create_schema = """CREATE SCHEMA IF NOT EXISTS indicina_schema"""
        create_fact_table = """
        CREATE TABLE IF NOT EXISTS indicina_schema.fact_table(
            application_id VARCHAR(50),
            customer_id VARCHAR(50)
        );"""
        create_loan_dim_table = """
            CREATE TABLE IF NOT EXISTS indicina_schema.loan_dim(
            application_id VARCHAR(50),
            customer_id VARCHAR(50),
            loan_amount INTEGER,
            loan_application_date DATE,
            credit_score INTEGER,
            employment_status VARCHAR(50),
            annual_income INTEGER
        );"""
        create_customer_dim_table = """
        CREATE TABLE IF NOT EXISTS indicina_schema.customer_dim(
            transaction_id VARCHAR(50),
            customer_id VARCHAR(50),
            transaction_date DATE,
            transaction_amount DECIMAL,
            narration VARCHAR(70),
            balance DECIMAL
        );
        """
        load_from_s3 = f"""
        COPY INTO indicina_schema.fact_table
        FROM 's3://{bucket}/fact_table'
        IAM_ROLE '{redshift_iam}';

        COPY INTO indicina_schema.loan_dim
        FROM 's3://{bucket}/loan_data'
        IAM_ROLE '{redshift_iam}';

        COPY INTO indicina_schema.customer_dim
        FROM 's3://{bucket}/customer_data'
        IAM_ROLE '{redshift_iam}';
        """
        try:
            with conn.cursor() as cursor:
                self.logger.info("Creating schema")
                cursor.execute(create_schema)

                self.logger.info("Creating fact tables")
                cursor.execute(create_fact_table)

                self.logger.info("Create loan dim table")
                cursor.execute(create_loan_dim_table)

                self.logger.info("create customer dim table")
                cursor.execute(create_customer_dim_table)

                self.logger.info("Loading to s3")
                cursor.execute(load_from_s3)
            conn.close()

        except Exception as err:
            self.logger.error(f"Error transforming dataframes. Msg:{err}")
            traceback.format_exc()
