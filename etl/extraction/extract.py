import pandas as pd
import traceback
from typing import Iterable
import os
import sys
current_path = os.getcwd()
sys.path.append(f"{os.path.dirname(current_path)}")
from utils import logger


class Extraction:
    def __init__(self, data_folder: str) -> None:
        self.data_folder = data_folder
        self.logger = logger()

    def read_csv(self, customer_path: str, loan_path: str) -> Iterable:
        load_data_path = f"\
                {os.path.dirname(current_path)}\
                /{self.data_folder}\
                /{loan_path}\
                /loan_data.csv"

        customer_data_path = f" \
                {os.path.dirname(current_path)}\
                /{self.data_folder}\
                /{customer_path}\
                /customer_data.csv"

        try:
            self.logger.info("Reading the customer dataframe ")
            customer_df = pd.read_csv(customer_data_path.replace(' ', ''))

            self.logger.info("Reading the loan application dataset")
            loan_df = pd.read_csv(load_data_path.replace(' ', ''))

            self.logger.info("Successfully read customer df and loan df")
            return (customer_df, loan_df)

        except Exception as err:
            self.logger.error(f"ERROR Reading dataframe. Error msg: {err}")
            traceback.format_exc()
