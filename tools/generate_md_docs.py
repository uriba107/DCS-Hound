#!/usr/bin/env python3
"""
HOUND Documentation Generator
Generates AI-optimized Markdown documentation from LDOC comments in Lua files
"""

import os
import re
import sys
import argparse
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass, field


@dataclass
class CommentBlock:
    """Represents a parsed LDOC comment block"""
    description: List[str] = field(default_factory=list)
    params: List[Dict[str, str]] = field(default_factory=list)
    returns: List[Dict[str, str]] = field(default_factory=list)
    fields: List[Dict[str, str]] = field(default_factory=list)
    usage: List[str] = field(default_factory=list)
    see: List[str] = field(default_factory=list)
    tags: Dict[str, str] = field(default_factory=dict)
    is_local: bool = False
    within: Optional[str] = None
    section: Optional[str] = None
    type_info: Optional[str] = None
    signature: Optional[Dict[str, Any]] = None


@dataclass
class FileData:
    """Represents parsed data from a single Lua file"""
    filepath: str
    filename: str
    modules: List[CommentBlock] = field(default_factory=list)
    functions: List[CommentBlock] = field(default_factory=list)
    tables: List[CommentBlock] = field(default_factory=list)
    sections: List[CommentBlock] = field(default_factory=list)
    global_comments: List[CommentBlock] = field(default_factory=list)


class LuaDocParser:
    """Parses LDOC comments from Lua source files"""
    
    # Regex patterns for LDOC parsing
    PATTERNS = {
        'MODULE': re.compile(r'^\s*---\s+(.+)\s*$'),
        'MODULE_DESC': re.compile(r'^\s*--+\s+(.+)\s*$'),
        'MODULE_TAG': re.compile(r'^\s*--+\s+@module\s+(.+)\s*$'),
        'SCRIPT_TAG': re.compile(r'^\s*--+\s+@script\s+(.+)\s*$'),
        'AUTHOR_TAG': re.compile(r'^\s*--+\s+@author\s+(.+)\s*$'),
        'COPYRIGHT_TAG': re.compile(r'^\s*--+\s+@copyright\s+(.+)\s*$'),
        'SECTION': re.compile(r'^\s*--+\s+@section\s+(.+)\s*$'),
        'FIELD': re.compile(r'^\s*--+\s+@field\s+(\S+)\s+(.+)\s*$'),
        'PARAM': re.compile(r'^\s*--+\s+@param\s*\[?([^\]\s]*)\]?\s*(\S+)\s+(.+)\s*$'),
        'RETURN': re.compile(r'^\s*--+\s+@return\s*\[?([^\]\s]*)\]?\s*(.+)\s*$'),
        'USAGE': re.compile(r'^\s*--+\s+@usage\s+(.+)\s*$'),
        'SEE': re.compile(r'^\s*--+\s+@see\s+(.+)\s*$'),
        'LOCAL': re.compile(r'^\s*--+\s+@local\s*$'),
        'WITHIN': re.compile(r'^\s*--+\s+@within\s+(.+)\s*$'),
        'TYPE': re.compile(r'^\s*--+\s+@type\s+(.+)\s*$'),
        'TABLE': re.compile(r'^\s*--+\s+@table\s+(.+)\s*$'),
        'FUNCTION_DEF': re.compile(r'^\s*function\s+([\w\.:]+)\s*\(([^)]*)\)'),
        'LOCAL_FUNCTION': re.compile(r'^\s*local\s+function\s+([\w\.:]+)\s*\(([^)]*)\)'),
        'TABLE_DEF': re.compile(r'^\s*([\w\.]+)\s*=\s*{'),
        'COMMENT_LINE': re.compile(r'^\s*--+\s*(.*)\s*$'),
        'BLOCK_COMMENT_START': re.compile(r'^\s*--\[\['),
        'BLOCK_COMMENT_END': re.compile(r'\]\]--?\s*$'),
    }
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
    
    def log(self, message: str) -> None:
        """Log a message if verbose mode is enabled"""
        if self.verbose:
            print(f"[INFO] {message}")
    
    def parse_ldoc_comment_block(self, lines: List[str], start_idx: int) -> Tuple[CommentBlock, int]:
        """Parse an LDOC comment block starting at the given line index"""
        comment_block = CommentBlock()
        i = start_idx
        in_block_comment = False
        
        # Check if this is a non-LDOC block comment (like --[[ Generic Functions ----]])
        if (i < len(lines) and 
            self.PATTERNS['BLOCK_COMMENT_START'].match(lines[i]) and 
            not any(tag in lines[i] for tag in ['@param', '@return', '@field', '@module', '@script', '@author', '@copyright', '@section', '@usage', '@see', '@local', '@within', '@type', '@table'])):
            # Skip non-LDOC block comments entirely
            while i < len(lines):
                if self.PATTERNS['BLOCK_COMMENT_END'].search(lines[i]):
                    i += 1
                    break
                i += 1
            return comment_block, i
        
        while i < len(lines):
            line = lines[i]
            
            # Check for block comment start/end
            if self.PATTERNS['BLOCK_COMMENT_START'].match(line):
                in_block_comment = True
            elif self.PATTERNS['BLOCK_COMMENT_END'].search(line):
                in_block_comment = False
                i += 1
                break
            
            # Skip non-comment lines if not in block comment
            if not in_block_comment and not line.strip().startswith('--'):
                break
            
            # Parse LDOC tags
            for tag_name, pattern in [
                ('module', self.PATTERNS['MODULE_TAG']),
                ('script', self.PATTERNS['SCRIPT_TAG']),
                ('author', self.PATTERNS['AUTHOR_TAG']),
                ('copyright', self.PATTERNS['COPYRIGHT_TAG']),
                ('table', self.PATTERNS['TABLE']),
            ]:
                match = pattern.match(line)
                if match:
                    comment_block.tags[tag_name] = match.group(1).strip()
            
            # Parse other tags
            match = self.PATTERNS['SECTION'].match(line)
            if match:
                comment_block.section = match.group(1).strip()
            
            match = self.PATTERNS['FIELD'].match(line)
            if match:
                comment_block.fields.append({
                    'name': match.group(1).strip(),
                    'description': match.group(2).strip()
                })
            
            match = self.PATTERNS['PARAM'].match(line)
            if match:
                comment_block.params.append({
                    'name': match.group(2).strip(),
                    'type': match.group(1).strip() or 'any',
                    'description': match.group(3).strip()
                })
            
            match = self.PATTERNS['RETURN'].match(line)
            if match:
                comment_block.returns.append({
                    'type': match.group(1).strip() or 'any',
                    'description': match.group(2).strip()
                })
            
            match = self.PATTERNS['USAGE'].match(line)
            if match:
                comment_block.usage.append(match.group(1).strip())
            
            match = self.PATTERNS['SEE'].match(line)
            if match:
                comment_block.see.append(match.group(1).strip())
            
            match = self.PATTERNS['WITHIN'].match(line)
            if match:
                comment_block.within = match.group(1).strip()
            
            match = self.PATTERNS['TYPE'].match(line)
            if match:
                comment_block.type_info = match.group(1).strip()
            
            if self.PATTERNS['LOCAL'].match(line):
                comment_block.is_local = True
            
            # Parse description lines
            match = self.PATTERNS['COMMENT_LINE'].match(line)
            if match and not line.strip().startswith('-- @') and line.strip() != '--':
                content = match.group(1).strip()
                if content:
                    comment_block.description.append(content)
            
            i += 1
        
        return comment_block, i
    
    def parse_function_signature(self, line: str) -> Optional[Tuple[str, List[str]]]:
        """Parse function signature from a line"""
        for pattern in [self.PATTERNS['FUNCTION_DEF'], self.PATTERNS['LOCAL_FUNCTION']]:
            match = pattern.match(line)
            if match:
                func_name = match.group(1)
                params_str = match.group(2)
                
                param_list = []
                if params_str.strip():
                    param_list = [p.strip() for p in params_str.split(',')]
                
                return func_name, param_list
        
        return None
    
    def parse_table_definition(self, line: str) -> Optional[str]:
        """Parse table definition from a line"""
        match = self.PATTERNS['TABLE_DEF'].match(line)
        if match:
            return match.group(1)
        return None
    
    def parse_lua_file(self, filepath: str) -> Optional[FileData]:
        """Parse a single Lua file and extract LDOC comments"""
        self.log(f"Parsing file: {filepath}")
        
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as file:
                content = file.read()
        except Exception as e:
            print(f"[ERROR] Could not read file {filepath}: {e}")
            return None
        
        lines = content.splitlines()
        file_data = FileData(
            filepath=filepath,
            filename=os.path.basename(filepath)
        )
        
        i = 0
        while i < len(lines):
            line = lines[i]
            
            # Check for comment blocks
            if line.strip().startswith('--'):
                comment_block, next_i = self.parse_ldoc_comment_block(lines, i)
                
                # Look for the next non-comment line to determine what this comment describes
                target_line_idx = next_i
                while target_line_idx < len(lines) and not lines[target_line_idx].strip():
                    target_line_idx += 1
                
                if target_line_idx < len(lines):
                    target_line = lines[target_line_idx]
                    
                    # Check if it's a function
                    func_sig = self.parse_function_signature(target_line)
                    if func_sig:
                        func_name, param_list = func_sig
                        comment_block.signature = {
                            'name': func_name,
                            'params': param_list
                        }
                        file_data.functions.append(comment_block)
                    
                    # Check if it's a table
                    table_name = self.parse_table_definition(target_line)
                    if table_name:
                        comment_block.signature = {
                            'name': table_name
                        }
                        file_data.tables.append(comment_block)
                
                # Handle module-level comments
                if comment_block.tags.get('module') or comment_block.tags.get('script'):
                    file_data.modules.append(comment_block)
                
                # Handle section comments
                if comment_block.section:
                    file_data.sections.append(comment_block)
                
                # Handle standalone comments and @table tags
                if (not comment_block.signature and 
                    not comment_block.tags.get('module') and 
                    not comment_block.tags.get('script') and 
                    not comment_block.section):
                    # If it has a @table tag, treat it as a table
                    if comment_block.tags.get('table'):
                        file_data.tables.append(comment_block)
                    else:
                        file_data.global_comments.append(comment_block)
                
                i = next_i
            else:
                i += 1
        
        return file_data


class MarkdownGenerator:
    """Generates Markdown documentation from parsed LDOC data"""
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
    
    def log(self, message: str) -> None:
        """Log a message if verbose mode is enabled"""
        if self.verbose:
            print(f"[INFO] {message}")
    
    def escape_markdown(self, text: str) -> str:
        """Escape special Markdown characters"""
        if not text:
            return ""
        return re.sub(r'([*_\[\]()])', r'\\\1', text)
    
    def format_function_doc(self, func_doc: CommentBlock) -> str:
        """Format a function's documentation as Markdown"""
        lines = []
        
        # Function signature
        if func_doc.signature:
            signature = func_doc.signature
            params_str = ', '.join(signature.get('params', []))
            lines.append(f"### `{signature['name']}({params_str})`")
            lines.append("")
        
        # Description
        if func_doc.description:
            lines.append(' '.join(func_doc.description))
            lines.append("")
        
        # Parameters
        if func_doc.params:
            lines.append("**Parameters:**")
            for param in func_doc.params:
                lines.append(f"- `{param['name']}` ({param['type']}): {param['description']}")
            lines.append("")
        
        # Returns
        if func_doc.returns:
            lines.append("**Returns:**")
            for ret in func_doc.returns:
                lines.append(f"- ({ret['type']}): {ret['description']}")
            lines.append("")
        
        # Usage examples
        if func_doc.usage:
            lines.append("**Usage:**")
            lines.append("```lua")
            lines.extend(func_doc.usage)
            lines.append("```")
            lines.append("")
        
        # See also
        if func_doc.see:
            lines.append("**See also:** " + ', '.join(func_doc.see))
            lines.append("")
        
        # Additional info
        if func_doc.within:
            lines.append(f"*Part of: {func_doc.within}*")
            lines.append("")
        
        if func_doc.is_local:
            lines.append("*Note: This is a local function*")
            lines.append("")
        
        return '\n'.join(lines)
    
    def format_table_doc(self, table_doc: CommentBlock) -> str:
        """Format a table's documentation as Markdown"""
        lines = []
        
        # Table name - check both signature and @table tag
        table_name = None
        if table_doc.signature:
            table_name = table_doc.signature['name']
        elif table_doc.tags.get('table'):
            table_name = table_doc.tags['table']
        
        if table_name:
            lines.append(f"### `{table_name}`")
            lines.append("")
        
        # Description
        if table_doc.description:
            lines.append(' '.join(table_doc.description))
            lines.append("")
        
        # Fields
        if table_doc.fields:
            lines.append("**Fields:**")
            for field in table_doc.fields:
                lines.append(f"- `{field['name']}`: {field['description']}")
            lines.append("")
        
        # Type information
        if table_doc.type_info:
            lines.append(f"**Type:** {table_doc.type_info}")
            lines.append("")
        
        return '\n'.join(lines)
    
    def generate_module_doc(self, file_data: FileData) -> str:
        """Generate documentation for a single module/file"""
        lines = []
        
        # Module header
        for module in file_data.modules:
            module_name = (module.tags.get('module') or 
                          module.tags.get('script') or 
                          "Unknown Module")
            lines.append(f"## {module_name}")
            lines.append("")
            
            if module.description:
                lines.append(' '.join(module.description))
                lines.append("")
            
            if module.tags.get('author'):
                lines.append(f"**Author:** {module.tags['author']}")
            if module.tags.get('copyright'):
                lines.append(f"**Copyright:** {module.tags['copyright']}")
            if module.tags.get('author') or module.tags.get('copyright'):
                lines.append("")
        
        # File information
        lines.append(f"**File:** `{file_data.filename}`")
        lines.append("")
        
        # Sections
        for section in file_data.sections:
            lines.append(f"### {section.section}")
            lines.append("")
            if section.description:
                lines.append(' '.join(section.description))
                lines.append("")
        
        # Tables
        if file_data.tables:
            lines.append("### Tables")
            lines.append("")
            for table_doc in file_data.tables:
                lines.append(self.format_table_doc(table_doc))
        
        # Functions
        if file_data.functions:
            lines.append("### Functions")
            lines.append("")
            for func_doc in file_data.functions:
                lines.append(self.format_function_doc(func_doc))
        
        return '\n'.join(lines)
    
    def generate_full_documentation(self, parsed_files: List[FileData]) -> str:
        """Generate complete documentation for all files"""
        lines = [
            "# HOUND ELINT System - Full API Documentation",
            "",
            "This document provides comprehensive API documentation for the HOUND ELINT system, automatically generated from LDOC comments in the source code.",
            "",
            f"*Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*",
            "",
            "## Overview",
            "",
            "The HOUND ELINT (Electronic Intelligence) system is a comprehensive radar detection and tracking system for DCS World. It provides real-time detection, classification, and tracking of enemy radar emitters with advanced triangulation algorithms.",
            "",
            "## Key Features",
            "",
            "- **Real-time radar detection**: Detects active radar emitters in the battlefield",
            "- **Advanced triangulation**: Uses multiple platform bearings for accurate position estimation", 
            "- **Automatic classification**: Identifies radar types and associated weapon systems",
            "- **Multi-platform support**: Works with various ELINT-capable aircraft",
            "- **Sector management**: Organizes contacts by geographical sectors",
            "- **Communication integration**: Provides automated reports via radio and text-to-speech",
            "- **Marker system**: Places visual markers on the F10 map",
            "",
        ]
        
        # Add table of contents
        lines.append("## Table of Contents")
        lines.append("")
        for file_data in parsed_files:
            for module in file_data.modules:
                module_name = (module.tags.get('module') or 
                              module.tags.get('script') or 
                              file_data.filename)
                anchor = re.sub(r'[^a-zA-Z0-9]+', '-', module_name.lower()).strip('-')
                lines.append(f"- [{module_name}](#{anchor})")
        lines.append("")
        
        # Add module documentation
        for file_data in parsed_files:
            lines.append(self.generate_module_doc(file_data))
            lines.append("---")
            lines.append("")
        
        return '\n'.join(lines)
    
    def generate_public_documentation(self, parsed_files: List[FileData]) -> str:
        """Generate public API documentation focusing on HoundElint module and non-local HOUND globals"""
        lines = [
            "# HOUND ELINT System - Public API Documentation",
            "",
            "This document provides public API documentation for the HOUND ELINT system, focusing on functions and classes intended for external use.",
            "",
            f"*Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*",
            "",
            "## Overview",
            "",
            "The HOUND ELINT system provides a public API for mission builders and other scripts to interact with the radar detection system.",
            "",
        ]
        
        # Process files in a specific order: HoundElint files first, then globals
        hound_elint_files = []
        global_files = []
        other_files = []
        
        for file_data in parsed_files:
            filename = file_data.filename
            if filename.startswith('800 -') or filename.startswith('801 -'):
                hound_elint_files.append(file_data)
            elif filename.startswith('000 -'):
                global_files.append(file_data)
            else:
                other_files.append(file_data)
        
        # Process HoundElint files (800, 801)
        for file_data in hound_elint_files:
            has_public_content = False
            public_functions = []
            public_tables = []
            
            # Include ALL functions from HoundElint files (they're the main public API)
            for func_doc in file_data.functions:
                if func_doc.signature:
                    func_name = func_doc.signature['name']
                    # Include HoundElint functions (both instance methods and static functions)
                    if (func_name.startswith('HoundElint') or 
                        (func_name.startswith('HOUND.') and not func_doc.is_local)):
                        public_functions.append(func_doc)
                        has_public_content = True
            
            # Include HoundElint tables
            for table_doc in file_data.tables:
                if table_doc.signature:
                    table_name = table_doc.signature['name']
                    if table_name.startswith('HoundElint') or table_name.startswith('HOUND.'):
                        public_tables.append(table_doc)
                        has_public_content = True
            
            # Add content for HoundElint files
            if has_public_content:
                for module in file_data.modules:
                    module_name = (module.tags.get('module') or 
                                  module.tags.get('script') or 
                                  "HoundElint")
                    lines.append(f"## {module_name}")
                    lines.append("")
                    
                    if module.description:
                        lines.append(' '.join(module.description))
                        lines.append("")
                    
                    if module.tags.get('author'):
                        lines.append(f"**Author:** {module.tags['author']}")
                    if module.tags.get('copyright'):
                        lines.append(f"**Copyright:** {module.tags['copyright']}")
                    if module.tags.get('author') or module.tags.get('copyright'):
                        lines.append("")
                
                # Add public tables
                if public_tables:
                    lines.append("### Tables and Types")
                    lines.append("")
                    for table_doc in public_tables:
                        lines.append(self.format_table_doc(table_doc))
                
                # Add public functions
                if public_functions:
                    lines.append("### Public Methods and Functions")
                    lines.append("")
                    for func_doc in public_functions:
                        lines.append(self.format_function_doc(func_doc))
                
                lines.append("---")
                lines.append("")
        
        # Process global files (000) - only non-local functions
        for file_data in global_files:
            has_public_content = False
            public_functions = []
            public_tables = []
            
            # Filter global functions (exclude local ones)
            for func_doc in file_data.functions:
                if not func_doc.is_local and func_doc.signature:
                    func_name = func_doc.signature['name']
                    # Include global HOUND functions that are not marked as local
                    if func_name.startswith('HOUND.'):
                        public_functions.append(func_doc)
                        has_public_content = True
            
            # Filter global tables (main configuration and enum tables, exclude local ones)
            for table_doc in file_data.tables:
                if table_doc.signature and not table_doc.is_local:
                    table_name = table_doc.signature['name']
                    if table_name.startswith('HOUND'):  # Changed from 'HOUND.' to 'HOUND' to include main HOUND table
                        public_tables.append(table_doc)
                        has_public_content = True
                # Also include standalone table documentation (like @table HOUND)
                elif table_doc.tags.get('table') and table_doc.tags['table'].startswith('HOUND'):
                    public_tables.append(table_doc)
                    has_public_content = True
            
            # Also check global comments for @table tags
            for comment_doc in file_data.global_comments:
                if comment_doc.tags.get('table') and comment_doc.tags['table'].startswith('HOUND'):
                    public_tables.append(comment_doc)
                    has_public_content = True
            
            # Add public global content
            if has_public_content:
                for module in file_data.modules:
                    module_name = (module.tags.get('module') or 
                                  module.tags.get('script') or 
                                  "HOUND Global API")
                    lines.append(f"## {module_name} - Global Functions")
                    lines.append("")
                    
                    if module.description:
                        lines.append(' '.join(module.description))
                        lines.append("")
                
                # Add public global tables
                if public_tables:
                    lines.append("### Global Configuration and Enums")
                    lines.append("")
                    for table_doc in public_tables:
                        lines.append(self.format_table_doc(table_doc))
                
                # Add public global functions
                if public_functions:
                    lines.append("### Global Utility Functions")
                    lines.append("")
                    for func_doc in public_functions:
                        lines.append(self.format_function_doc(func_doc))
                
                lines.append("---")
                lines.append("")
        
        return '\n'.join(lines)


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Generate AI-optimized Markdown documentation from LDOC comments"
    )
    parser.add_argument(
        "--src-dir", 
        default="../src", 
        help="Source directory containing Lua files (default: ../src)"
    )
    parser.add_argument(
        "--public-output-dir", 
        default="../docs", 
        help="Output directory for public API documentation (default: ../docs)"
    )
    parser.add_argument(
        "--dev-output-dir", 
        default="../docs/dev", 
        help="Output directory for developer documentation (default: ../docs/dev)"
    )
    parser.add_argument(
        "--verbose", "-v", 
        action="store_true", 
        help="Enable verbose output"
    )
    
    args = parser.parse_args()
    
    # Initialize components
    parser_instance = LuaDocParser(verbose=args.verbose)
    generator = MarkdownGenerator(verbose=args.verbose)
    
    if args.verbose:
        print("Starting HOUND documentation generation...")
    
    # Ensure output directories exist
    public_output_path = Path(args.public_output_dir)
    dev_output_path = Path(args.dev_output_dir)
    public_output_path.mkdir(parents=True, exist_ok=True)
    dev_output_path.mkdir(parents=True, exist_ok=True)
    
    # Get all Lua files in src directory
    src_path = Path(args.src_dir)
    if not src_path.exists():
        print(f"[ERROR] Source directory does not exist: {src_path}")
        return 1
    
    lua_files = list(src_path.glob("*.lua"))
    if not lua_files:
        print(f"[ERROR] No Lua files found in: {src_path}")
        return 1
    
    if args.verbose:
        print(f"Found {len(lua_files)} Lua files to process")
    
    # Parse all files
    parsed_files = []
    for filepath in sorted(lua_files):
        file_data = parser_instance.parse_lua_file(str(filepath))
        if file_data:
            parsed_files.append(file_data)
    
    if args.verbose:
        print(f"Successfully parsed {len(parsed_files)} files")
    
    # Generate public API documentation (for AI agents and users)
    public_doc = generator.generate_public_documentation(parsed_files)
    public_api_path = public_output_path / "HOUND_API_REFERENCE.md"
    
    try:
        with open(public_api_path, 'w', encoding='utf-8') as f:
            f.write(public_doc)
        if args.verbose:
            print(f"Generated public API documentation: {public_api_path}")
    except Exception as e:
        print(f"[ERROR] Could not write public API documentation: {e}")
        return 1
    
    # Generate full developer documentation
    full_doc = generator.generate_full_documentation(parsed_files)
    dev_api_path = dev_output_path / "DEVELOPER_API_REFERENCE.md"
    
    try:
        with open(dev_api_path, 'w', encoding='utf-8') as f:
            f.write(full_doc)
        if args.verbose:
            print(f"Generated developer documentation: {dev_api_path}")
    except Exception as e:
        print(f"[ERROR] Could not write developer documentation: {e}")
        return 1
    
    if args.verbose:
        print("Documentation generation completed successfully!")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
