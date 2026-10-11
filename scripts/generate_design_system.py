#!/usr/bin/env python3
"""
Design System Swift Asset Generator
Scans Xcode Asset Catalogs (.xcassets) for .colorset and .imageset folders
and generates type-safe, namespaced Swift accessors for SwiftUI and UIKit.
"""

import os
import sys
import json
import re
import argparse
from typing import Optional

SWIFT_RESERVED_KEYWORDS = {
    "associatedtype", "class", "deinit", "enum", "extension", "fileprivate",
    "func", "import", "init", "inout", "internal", "let", "open", "operator",
    "private", "precedencegroup", "protocol", "public", "rethrows", "static",
    "struct", "subscript", "typealias", "var", "break", "case", "catch",
    "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard",
    "if", "in", "repeat", "return", "throw", "switch", "where", "while",
    "as", "any", "false", "is", "nil", "self", "Self", "super", "true",
    "try", "some", "Protocol", "Type"
}


def sanitize_swift_identifier(name: str) -> str:
    """Converts an arbitrary string (e.g. 'primary-text', 'logo_placeholder', 'elevatedSurface') into a valid Swift identifier."""
    if not name:
        return "unnamed"
    
    words = re.findall(r'[A-Z]?[a-z0-9]+|[A-Z]+(?=[A-Z][a-z0-9]|\b)', name)
    if not words:
        words = [name]
    
    first_word = words[0].lower()
    capitalized_words = [w.capitalize() for w in words[1:]]
    identifier = first_word + "".join(capitalized_words)
    
    if identifier[0].isdigit():
        identifier = f"v{identifier}"
        
    if identifier in SWIFT_RESERVED_KEYWORDS:
        return f"`{identifier}`"
        
    return identifier


class GeneratorError(Exception):
    pass


HANDWRITTEN_START = "// MARK: - Handwritten (preserved by generator)"
HANDWRITTEN_END = "// MARK: - End Handwritten"


def extract_handwritten(text: str) -> str:
    start = text.find(HANDWRITTEN_START)
    if start == -1:
        return ""
    end = text.find(HANDWRITTEN_END, start)
    if end == -1:
        return text[start:].rstrip()
    return text[start:end + len(HANDWRITTEN_END)].rstrip()


class DesignSystemAssetGenerator:
    def __init__(self, assets_dir: str, output_dir: str, symbols_file: Optional[str] = None,
                 icons_dir: Optional[str] = None):
        self.assets_dir = assets_dir
        self.icons_dir = icons_dir or assets_dir
        self.output_dir = output_dir
        self.symbols_file = symbols_file

    def scan_asset_catalog(self) -> tuple[list[str], list[str]]:
        if not os.path.exists(self.assets_dir):
            raise GeneratorError(f"Asset catalog directory does not exist: {self.assets_dir}")

        color_names = []
        image_names = []

        for root, dirs, files in os.walk(self.assets_dir):
            for d in dirs:
                if d.endswith('.colorset'):
                    name = d[:-9]
                    color_names.append(name)
                elif d.endswith('.imageset'):
                    name = d[:-9]
                    image_names.append(name)

        if os.path.abspath(self.icons_dir) != os.path.abspath(self.assets_dir):
            if not os.path.exists(self.icons_dir):
                raise GeneratorError(f"Icon asset catalog directory does not exist: {self.icons_dir}")
            for root, dirs, _ in os.walk(self.icons_dir):
                for d in dirs:
                    if d.endswith('.imageset'):
                        image_names.append(d[:-9])

        color_names.sort()
        image_names.sort()

        # Validate duplicate normalized identifiers
        self._validate_collisions(color_names, "color set")
        self._validate_collisions(image_names, "image set")

        return color_names, image_names

    def scan_symbol_aliases(self) -> list[tuple[str, str]]:
        if not self.symbols_file or not os.path.exists(self.symbols_file):
            return []
        with open(self.symbols_file, "r", encoding="utf-8") as handle:
            try:
                data = json.load(handle)
            except json.JSONDecodeError as exc:
                raise GeneratorError(f"Invalid symbols JSON: {exc}") from exc
        if not isinstance(data, dict):
            raise GeneratorError("Symbols JSON must be an object of {alias: sfSymbolName}")
        aliases = []
        for key, value in data.items():
            if not isinstance(key, str) or not isinstance(value, str):
                raise GeneratorError("Symbol alias keys and values must be strings")
            aliases.append((key, value))
        aliases.sort(key=lambda item: item[0])
        self._validate_collisions([key for key, _ in aliases], "symbol alias")
        return aliases

    def _validate_collisions(self, names: list[str], asset_type: str):
        mapped = {}
        for name in names:
            swift_id = sanitize_swift_identifier(name)
            raw_id = swift_id.strip('`')
            if raw_id in mapped:
                raise GeneratorError(f"Naming collision in {asset_type}: '{name}' and '{mapped[raw_id]}' both normalize to identifier '{raw_id}'")
            mapped[raw_id] = name

    def generate_swift_code(self) -> str:
        color_names, image_names = self.scan_asset_catalog()

        lines = [
            "// Auto-generated by generate_design_system.py. DO NOT EDIT DIRECTLY.",
            "import SwiftUI",
            "import UDSCore",
            "#if canImport(UIKit)",
            "import UIKit",
            "#endif",
            "#if canImport(AppKit)",
            "import AppKit",
            "#endif",
            "",
            "// MARK: - UDSColor Asset Accessors",
            "public struct UDSColor: Sendable {",
            "    public static let uiKit = UDSColorUIKitProxy()",
            "    private static func resolve(_ name: String) -> Color {",
            "        #if canImport(UIKit)",
            "        if let color = UIColor(named: name) { return Color(uiColor: color) }",
            "        if let color = UIColor(named: name, in: UDSBundle.module, compatibleWith: nil) { return Color(uiColor: color) }",
            "        #elseif canImport(AppKit)",
            "        if let color = NSColor(named: NSColor.Name(name), bundle: .main) { return Color(nsColor: color) }",
            "        if let color = NSColor(named: NSColor.Name(name), bundle: UDSBundle.module) { return Color(nsColor: color) }",
            "        #endif",
            "        return .clear",
            "    }"
        ]

        for name in color_names:
            swift_id = sanitize_swift_identifier(name)
            lines.append(f'    public static var {swift_id}: Color {{ resolve("{name}") }}')

        lines.extend([
            "}",
            "",
            "public struct UDSColorUIKitProxy: Sendable {"
        ])

        for name in color_names:
            swift_id = sanitize_swift_identifier(name)
            lines.append("    #if canImport(UIKit)")
            lines.append(f'    public var {swift_id}: UIColor {{ UIColor(named: "{name}") ?? UIColor(named: "{name}", in: UDSBundle.module, compatibleWith: nil) ?? .clear }}')
            lines.append("    #endif")

        lines.extend([
            "}",
            "",
            "// MARK: - UDSImage Asset Accessors",
            "public struct UDSImage: Sendable {",
            "    public static let uiKit = UDSImageUIKitProxy()"
        ])

        for name in image_names:
            swift_id = sanitize_swift_identifier(name)
            lines.append(f'    public static var {swift_id}: Image {{ Image("{name}", bundle: UDSBundle.module) }}')

        lines.extend([
            "}",
            "",
            "public struct UDSImageUIKitProxy: Sendable {"
        ])

        for name in image_names:
            swift_id = sanitize_swift_identifier(name)
            lines.append("    #if canImport(UIKit)")
            lines.append(f'    public var {swift_id}: UIImage? {{ UIImage(named: "{name}", in: UDSBundle.module, compatibleWith: nil) }}')
            lines.append("    #endif")

        lines.append("}")

        aliases = self.scan_symbol_aliases()
        if aliases:
            lines.extend([
                "",
                "// MARK: - Typed SF Symbol Tokens",
                "public extension UDSIconToken {"
            ])
            for alias, symbol in aliases:
                swift_id = sanitize_swift_identifier(alias)
                lines.append(f'    static let {swift_id} = UDSIconToken.symbol("{symbol}")')
            lines.append("}")

        bundled_icon_names = [name for name in image_names if name.startswith("outline-")]
        if bundled_icon_names:
            lines.extend([
                "",
                "// MARK: - Typed Bundled SVG Icon Tokens",
                "public extension UDSIconToken {"
            ])
            for name in bundled_icon_names:
                swift_id = sanitize_swift_identifier(name)
                lines.append(f'    static let {swift_id} = UDSIconToken.asset("{name}")')
            lines.extend([
                "}",
                "",
                "/// All bundled SVG icons, paired with their stable kebab-case asset names.",
                "public enum UDSIconAssets {",
                "    public static let all: [(name: String, token: UDSIconToken)] = ["
            ])
            for name in bundled_icon_names:
                swift_id = sanitize_swift_identifier(name)
                lines.append(f'        ("{name.removeprefix("outline-")}", .{swift_id}),')
            lines.extend([
                "    ]",
                "}"
            ])

        return "\n".join(lines) + "\n"

    def _compose_output(self, generated_code: str, existing: Optional[str]) -> str:
        handwritten = extract_handwritten(existing) if existing else ""
        if handwritten:
            return generated_code.rstrip() + "\n\n" + handwritten + "\n"
        return generated_code

    def run(self, check=False, report=False) -> bool:
        generated_code = self.generate_swift_code()
        out_path = os.path.join(self.output_dir, "GeneratedAssets.swift")
        existing = None
        if os.path.exists(out_path):
            with open(out_path, "r", encoding="utf-8") as handle:
                existing = handle.read()
        composed = self._compose_output(generated_code, existing)

        if report:
            print(f"[REPORT] Output File: {out_path}")
            print(f"[REPORT] Generated Content ({len(composed)} bytes):")
            print(composed)

        if check:
            if existing is None:
                raise GeneratorError(f"Generated file is missing: {out_path}")
            if existing != composed:
                raise GeneratorError(f"Generated file is outdated: {out_path}. Run 'python3 scripts/generate_design_system.py' to update.")
            print("[SUCCESS] Check passed: generated file is up-to-date.")
            return True

        self._write_if_changed(out_path, composed)
        print("[SUCCESS] Successfully generated Swift asset accessors.")
        return True

    def _write_if_changed(self, path: str, content: str):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        if os.path.exists(path):
            with open(path, 'r', encoding='utf-8') as f:
                existing = f.read()
            if existing == content:
                print(f"[UNCHANGED] {path}")
                return
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"[WRITTEN] {path}")


def main():
    parser = argparse.ArgumentParser(description="Generate Swift accessors from Xcode Asset Catalogs.")
    parser.add_argument("--assets-dir", default="Sources/UDSResources/Resources.xcassets", help="Path to Xcode asset catalog")
    parser.add_argument("--icons-dir", default="Sources/UDSResources/Icons.xcassets", help="Path to the separate custom icon image catalog")
    parser.add_argument("--output-dir", default="Sources/UDSResources", help="Output directory for generated Swift accessors")
    parser.add_argument("--symbols-file", default="Sources/UDSResources/symbols.json", help="JSON file mapping common icon aliases to SF Symbol names")
    parser.add_argument("--check", action="store_true", help="Validation-only mode. Exits with error if generated file is missing or outdated.")
    parser.add_argument("--report", action="store_true", help="Report details of generated code")

    args = parser.parse_args()

    generator = DesignSystemAssetGenerator(
        assets_dir=args.assets_dir,
        output_dir=args.output_dir,
        symbols_file=args.symbols_file,
        icons_dir=args.icons_dir
    )

    try:
        generator.run(check=args.check, report=args.report)
    except GeneratorError as e:
        print(f"[ERROR] {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
