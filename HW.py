import os
import logging

# Set up logging to a file
logging.basicConfig(filename='output.log', level=logging.INFO)

logging.debug('Starting program...')
logging.info(os.environ['HW'])
logging.debug('Program finished.')

