#!/usr/bin/env python3
"""Prompt assembly. No Comfy needed."""

import unittest

from prompt import CLASSES, assemble


class PromptTests(unittest.TestCase):
    def test_white_lock_and_subject(self):
        pos, neg = assemble("a hat on a round bust, meaning role", kind="persona")
        self.assertIn("pure white field", pos)
        self.assertIn("noun subclass persona", pos)
        self.assertIn("a hat on a round bust, meaning role", pos)
        self.assertIn("orange", neg)
        self.assertNotIn("Portal chamber", pos)
        self.assertNotIn("Valve", pos)

    def test_sign_field(self):
        pos, _ = assemble("empty slot", kind="null", field="sign")
        self.assertIn("pure black sign face", pos)
        self.assertIn("null tile", pos)

    def test_rejects_empty_and_bad_class(self):
        with self.assertRaises(ValueError):
            assemble("   ")
        with self.assertRaises(ValueError):
            assemble("wrench", kind="weapon")

    def test_every_class_has_a_line(self):
        self.assertGreaterEqual(len(CLASSES), 6)
        for key in CLASSES:
            pos, _ = assemble("test mark", kind=key)
            self.assertIn(CLASSES[key], pos)


if __name__ == "__main__":
    unittest.main()
