import unittest
from tests import suite

runner = unittest.TextTestRunner(verbosity=2)
runner.run(suite)
