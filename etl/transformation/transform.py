import pandas as pd
from typing import Iterable
import traceback
import sys
import os
current_path = os.getcwd()
sys.path.append(f"{os.path.dirname(current_path)}")
from utils import logger

loan_dtype_mapping = {
    "application_id": "object",
    "customer_id": "object",
    "loan_amount": "int64",
    "loan_application_date": "datetime64[ns]",
    "credit_score": "int64",
    "employment_status": "object",
    "annual_income": "int64"
}
customer_dtype_mapping = {
    "transaction_id": "object",
    "customer_id": "object",
    "transaction_date": "datetime64[ns]",
    "transaction_amount": "float64",
    "narration": "object",
    "balance": "float64"
}


class Transformation:
    def __init__(self) -> None:
        self.logger = logger()

    def transform(self,
                  customer_df: pd.core.frame.DataFrame,
                  loan_df: pd.core.frame.DataFrame
                  ) -> Iterable:
        try:
            """ Converting columns to lowercase """
            self.logger.info("Converting column types to lowercase")
            customer_df.columns = map(str.lower, customer_df.columns)
            loan_df.columns = map(str.lower, loan_df.columns)

            """Converting dtypes to match requirements"""
            customer_df = customer_df.astype(dtype=customer_dtype_mapping)
            loan_df = loan_df.astype(dtype=loan_dtype_mapping)

            """Creating fact table"""
            self.logger.info("Creating fact table")
            fact_table = loan_df[["application_id", "customer_id"]]
            self.logger.info("Fact table successfully created")

            return (customer_df, loan_df, fact_table)

        except Exception as err:
            self.logger.error(f"Error transforming dataframes. Msg:{err}")
            traceback.format_exc()
