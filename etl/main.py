from extraction.extract import Extraction
from transformation.transform import Transformation
from loading.load import Loading
import os
redshift_connection = "test_redshift"
s3_bucket = os.environ["S3_BUCKET_NAME"]
redshift_db = os.environ["REDSHIFT_DB_NAME"]
redshift_iam = os.environ["REDSHIFT_IAM_ROLE"]


def main():
    extract = Extraction("data")
    customer_df, loan_df = extract.read_csv("customer_bank_statement",
                                            "loan_application")
    customer_transformed, loan_transformed, fact_table = Transformation().\
        transform(
            customer_df, loan_df
    )
    loading_instance = Loading()
    loading_instance.convert_to_csv(
        customer_transformed,
        loan_transformed,
        fact_table
    )
    loading_instance.write_to_s3(s3_bucket)
    loading_instance.load_redshift(redshift_connection, s3_bucket,
                                   redshift_iam, redshift_db)


def lambda_handler(event, context):
    main()
