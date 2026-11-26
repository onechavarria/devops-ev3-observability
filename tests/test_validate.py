import unittest
from scripts.validate import validate


class ManifestTests(unittest.TestCase):
    def test_manifest_policies(self):
        self.assertEqual(validate(), [])


if __name__ == "__main__":
    unittest.main()
