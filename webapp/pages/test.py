from django.test import TestCase


class FakeTstCase(TestCase):
    # Until other test are added, this is a fake test
    def test_fake(self):
        self.assertTrue(True)
