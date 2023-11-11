import logging


def logger():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s ::%(levelname)s::%(name)s --> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )
    logger = logging.getLogger(__name__)
    return logger
