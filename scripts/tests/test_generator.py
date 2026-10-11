#!/usr/bin/env python3
"""
Unit tests for Python Design System Asset Generator
"""

import unittest
import tempfile
import shutil
import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from generate_design_system import (
    sanitize_swift_identifier,
    DesignSystemAssetGenerator,
    GeneratorError
)

class TestAssetGenerator(unittest.TestCase):
    def test_sanitize_swift_identifier_normal(self):
        self.assertEqual(sanitize_swift_identifier("primary_text"), "primaryText")
        self.assertEqual(sanitize_swift_identifier("elevated-surface"), "elevatedSurface")
        self.assertEqual(sanitize_swift_identifier("logo_placeholder"), "logoPlaceholder")

    def test_sanitize_swift_identifier_leading_digit(self):
        self.assertEqual(sanitize_swift_identifier("3d_view"), "v3dView")

    def test_sanitize_swift_identifier_reserved_keyword(self):
        self.assertEqual(sanitize_swift_identifier("default"), "`default`")
        self.assertEqual(sanitize_swift_identifier("public"), "`public`")

    def test_collision_detection(self):
        temp_dir = tempfile.mkdtemp()
        try:
            assets_dir = os.path.join(temp_dir, "Resources.xcassets")
            os.makedirs(os.path.join(assets_dir, "primary-text.colorset"))
            os.makedirs(os.path.join(assets_dir, "primary_text.colorset"))

            gen = DesignSystemAssetGenerator(
                assets_dir=assets_dir,
                output_dir=temp_dir
            )

            with self.assertRaises(GeneratorError) as ctx:
                gen.scan_asset_catalog()
            self.assertIn("Naming collision", str(ctx.exception))
        finally:
            shutil.rmtree(temp_dir)

    def test_generator_run_and_check(self):
        temp_dir = tempfile.mkdtemp()
        try:
            assets_dir = os.path.join(temp_dir, "Resources.xcassets")
            os.makedirs(os.path.join(assets_dir, "primary.colorset"))
            os.makedirs(os.path.join(assets_dir, "logo_hero.imageset"))

            out_dir = os.path.join(temp_dir, "out")

            gen = DesignSystemAssetGenerator(
                assets_dir=assets_dir,
                output_dir=out_dir
            )

            # First run writes file
            gen.run()
            generated_file = os.path.join(out_dir, "GeneratedAssets.swift")
            self.assertTrue(os.path.exists(generated_file))

            with open(generated_file, 'r') as f:
                content = f.read()
            self.assertIn("public static var primary: Color", content)
            self.assertIn("public static var logoHero: Image", content)

            # Second run with --check passes
            self.assertTrue(gen.run(check=True))
        finally:
            shutil.rmtree(temp_dir)

    def test_preserves_handwritten_block(self):
        temp_dir = tempfile.mkdtemp()
        try:
            assets_dir = os.path.join(temp_dir, "Resources.xcassets")
            os.makedirs(os.path.join(assets_dir, "primary.colorset"))
            out_dir = os.path.join(temp_dir, "out")
            gen = DesignSystemAssetGenerator(assets_dir=assets_dir, output_dir=out_dir)
            gen.run()

            generated_file = os.path.join(out_dir, "GeneratedAssets.swift")
            with open(generated_file, "a") as handle:
                handle.write("\n// MARK: - Handwritten (preserved by generator)\n")
                handle.write("public let handwrittenMarker = true\n")
                handle.write("// MARK: - End Handwritten\n")

            gen.run()
            with open(generated_file, "r") as handle:
                content = handle.read()
            self.assertIn("handwrittenMarker", content)
            self.assertIn("public static var primary: Color", content)
        finally:
            shutil.rmtree(temp_dir)

    def test_symbol_aliases(self):
        temp_dir = tempfile.mkdtemp()
        try:
            assets_dir = os.path.join(temp_dir, "Resources.xcassets")
            os.makedirs(assets_dir)
            symbols = os.path.join(temp_dir, "symbols.json")
            with open(symbols, "w") as handle:
                handle.write('{"appLogo": "applelogo", "settings": "gearshape"}')
            gen = DesignSystemAssetGenerator(
                assets_dir=assets_dir,
                output_dir=os.path.join(temp_dir, "out"),
                symbols_file=symbols
            )
            gen.run()
            generated_file = os.path.join(temp_dir, "out", "GeneratedAssets.swift")
            with open(generated_file, "r") as handle:
                content = handle.read()
            self.assertIn("public extension UDSIconToken", content)
            self.assertIn('static let appLogo = UDSIconToken.symbol("applelogo")', content)
        finally:
            shutil.rmtree(temp_dir)

if __name__ == '__main__':
    unittest.main()
