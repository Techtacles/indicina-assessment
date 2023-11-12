# indicina-assessment
This is a repository for indicina DE assessment.
			PROBLEM STATEMENT
The challenge involves tasks related to data engineering for credit risk assessment at Indicina. As a Senior Data Engineer, you are required to design a data warehouse schema integrating loan application and customer bank statement data efficiently, considering millions of observations. This involves specifying tables, relationships, and keys while addressing data types and quality issues. The second task involves developing a high-level ETL process to populate the data warehouse, including steps, transformations, and tools/technologies. The final task is to choose a BI tool (e.g., Tableau, Power BI, Looker, Quicksight) to design a sample dashboard with KPIs, visualizations, and interactivity options. 

			
			MY APPROACH
In crafting the solution, I aimed for a production-ready setup, opting for AWS as my cloud provider of choice. I employed Terraform to provision various AWS services, such as Amazon ECR which is an artifact registry for storing Docker images, AWS Lambda for data processing. This also involved writing data to S3, creating Redshift tables, and loading transformed data from S3 into Redshift. The reason I used AWS Lambda instead of AWS Glue or EMR is that Lambda is serverless, hence it is cost effective whilst compared to Glue or EMR. Lambda runs on docker containers, hence it is very fast. 

Amazon Redshift was also used as a data warehouse, where the transformed data was stored. To facilitate seamless integration between AWS Data Wrangler and Redshift, I leveraged the AWS Glue data connector, ensuring a smooth flow of data and optimizing the efficiency of the ETL process.

For creating insightful visualizations and reports, I turned to AWS QuickSight, a business intelligence tool that seamlessly integrates with various AWS data sources. This choice allowed for the creation of dynamic and interactive dashboards, providing stakeholders with a comprehensive view of the data and facilitating data-driven decision-making. I used Amazon Quicksight here because the solution was within a VPC in AWS and I did not want to allow connections outside the VPC to  Amazon Redshift. 

			ARCHITECTURE
The archiecture and the end to end flow of my solution is shown in the image below. The diagram encapsulates the holistic design thinking behind the solution, providing a clear and concise overview of how each element connects with other elements and contributes to the final solution.

![architecture](https://github.com/Techtacles/indicina-assessment/assets/57522480/0b77df95-90aa-404c-b29d-5ccf5ae04ebd)





			GITHUB REPO
The source code for the end to end process is in the Github repository
https://github.com/Techtacles/indicina-assessment

This Github repository contains some folders such as data. The data folder contains the data files in csv format. The etl folder contains the end to end ETL process of extracting the data from the data folder, transforming the data, mapping data types, primary key constraints and then loading the data to S3 and the Amazon Redshift data warehouse. The infrastructure folder contains the Terraform code for building and provisioning the AWS resources that were used in this project. The .github folder contains the workflow for the CICD, to ensure automated and continuous deployment of code changes to AWS. The images folder contains images and screenshots of the working code on the AWS portal. The dashboard folder contains the Quicksight dashboard image. 

			AMAZON ECR
The Amazon ECR resource used was created using Terraform. The dockerfile in the source repo was built and pushed to ECR using null_resource in Terraform. This pushes the latest image anytime there is a change in code to the ETL process. 

			AWS LAMBDA
AWS Lambda was used for running the ETL code from the Amazon ECR repository. The lambda function first extracts the data from the data source, runs some transformation on the data. The transformation done here was mapping the column types, converting date columns from string to python’s datetime data type, converting column names to lower case and creating the fact table. It then writes the transformed data to a location in S3 and also to the Amazon Redshift data warehouse.

The image for Lambda writing the transformed data to S3 is shown below.<img width="1163" alt="s3_bucket_paths" src="https://github.com/Techtacles/indicina-assessment/assets/57522480/6255f190-7192-4958-a082-8408859a79f3">


The image for Lambda writing the transformed data into Redshift is also shown below.
<img width="344" alt="tables_created_in_redshift" src="https://github.com/Techtacles/indicina-assessment/assets/57522480/adee50dc-ae82-4feb-8a85-d7bd347125d8">


As shown above, the tables created by lambda are the fact tables, customer dimension table, merged table and a join of the customer_dim and loan_dim as merged_table.

The successful running of Lambda is shown in  the image below
<img width="1395" alt="lambda_success" src="https://github.com/Techtacles/indicina-assessment/assets/57522480/1b75c616-636d-4120-b5b4-777c0a5ff814">


## AMAZON REDSHIFT
The data warehouse used in this project was Amazon Redshift. It was also created via Terraform. It contains four tables which were created by Amazon Lambda. I utilized Star Schema for the data model design. The data model designed is shown below

Also, I previewed the data in Redshift to be sure it matched the transformation I wrote. 
The image shown below is the data in Amazon Redshift.

<img width="1374" alt="selecting_tables" src="https://github.com/Techtacles/indicina-assessment/assets/57522480/dafb7c43-b224-4bbd-8920-fd5e0bfd45f9">


## QUICKSIGHT
I used Amazon Quicksight for creating the dashboards and reports. First, I created a data source which references the merged_table in AWS Redshift. This merged table was then used to create the visualizations and the reports.
The image of the visualization is shown below
<br>
<img width="1147" alt="dashboard" src="https://github.com/Techtacles/indicina-assessment/assets/57522480/770139cb-9f7e-4fba-b73c-1ff7c86a4d35">


## INSIGHTS FROM THE VISUALIZATION
From this report, we can get the following insights:<br>
1.) The average annual income is about 51,283.33<br><br>
2.) There is an average of over 800 transactions processed<br><br>
3.) As expected, the people with the highest average annual income are self employed with their private businesses. The people with the lowest average income are unemployed. <br><br>
4.) The highest transaction comes from people’s monthly income , fuel purchases and the lowest transactions are from utility bill payments. This is quite rational because of the fuel scarcity and it is logical for people to spend more to get fuel for their vehicles and generators. <br><br>
5.) As expected also, the highest loans requested are from people that are self employed with their own personal businesses. This is because it costs more to run a business and there are lot of business expenses they would incur, which they might now have the resources to fund at the moment. Hence, they request for a loan. Similarly, the lowest loan requested are from unemployed people. <br>

## TERRAFORM
Terraform was used to provision the AWS resources mentioned above. Terraform was used to automate the end to end process of creating and destroying AWS resoures. It is important to  note that there were few things I created manually. One of such was the Glue data connection. This was created manually because Terraform does not currently support Redshift data connector. It only supports JDBC, Mongodb, Kafka, amongst others. I also created VPC Endpoint manually. Glue data connection would not work without a VPC endpoint or a NAT Gateway. 


	
## GITHUB ACTIONS
CICD was also implemented in this solution. The goal was to make the solution a reproducible, automated solution. For every change you push, the CICD pipeline gets triggered and it updates with your latest changes. In Github Actions, I added some secrets to the Github Actions workflow such as the AWS OIDC role which authenticates the Github Actions to AWS. Another secret I added was the terraform.tfvars . This tfvars initializes all the variables in the root variables.tf .

## CONCLUSION
The Github repository is https://github.com/Techtacles/indicina-assessment
Feel free to check out the project and I’d be glad to answer any questions you might have.
