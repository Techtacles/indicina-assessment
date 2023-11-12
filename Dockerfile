FROM public.ecr.aws/lambda/python:3.10
#install dependencies in requirements.txt 
WORKDIR "${LAMBDA_TASK_ROOT}"
COPY /data .
COPY /etl .
RUN pip install -r requirements.txt
CMD ["main.lambda_handler"]
