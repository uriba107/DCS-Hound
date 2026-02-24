#!/usr/bin/env python3
"""
HOUND Documentation Generator
Generates AI-optimized Markdown documentation from LDOC comments in Lua files

Requirements: pip3 install -r requirements.txt
"""

import os
import re
import sys
import json
import argparse
import requests
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
    
    def __init__(self, verbose: bool = False, num_ctx: Optional[int] = None,
                 llm_timeout: int = 300, llm_host: Optional[str] = None):
        self.verbose = verbose
        self.num_ctx = num_ctx
        self.llm_timeout = llm_timeout
        self.llm_host = llm_host or self._resolve_ollama_host()
        if self.verbose:
            print(f"[INFO] Ollama host: {self.llm_host}")
    
    @staticmethod
    def _resolve_ollama_host() -> str:
        """Resolve Ollama API host. Priority:
        1. OLLAMA_HOST env var (Ollama's own convention)
        2. Auto-detect WSL -> use Windows host IP
        3. Fall back to localhost
        """
        # 1. Env var (Ollama convention)
        env_host = os.environ.get('OLLAMA_HOST')
        if env_host:
            # Normalize: add scheme if missing
            if not env_host.startswith('http'):
                env_host = f"http://{env_host}"
            return env_host.rstrip('/')
        
        # 2. Auto-detect WSL
        try:
            with open('/proc/version', 'r') as f:
                if 'microsoft' in f.read().lower():
                    print("is windows")
                    # WSL detected — read Windows host IP from resolv.conf
                    import socket
                    return f"http://{socket.gethostname()}.local:11434"
        except (FileNotFoundError, IndexError, PermissionError):
            pass
        
        # 3. Default
        return "http://localhost:11434"
    
    def log(self, message: str) -> None:
        """Log a message if verbose mode is enabled"""
        if self.verbose:
            print(f"[INFO] {message}")
    
    def check_ollama_available(self) -> bool:
        """Check if Ollama is reachable at the configured host"""
        try:
            response = requests.get(f"{self.llm_host}/api/tags", timeout=5)
            return response.status_code == 200
        except (requests.exceptions.ConnectionError, requests.exceptions.Timeout):
            return False
    
    def call_local_llm(self, prompt: str, model: str = "qwen3:4b") -> Optional[str]:
        """Call local Ollama LLM for text generation"""
        try:
            self.log(f"Calling Ollama model: {model}")
            
            timeout = self.llm_timeout
            llm_hostname = f"{self.llm_host}/api/generate"
            options = {
                "temperature": 0.3  # Lower temperature for more consistent output
            }
            if self.num_ctx is not None:
                options["num_ctx"] = self.num_ctx
            llm_body = {
                    "model": model,
                    "prompt": prompt,
                    "stream": False,
                    "options": options
                }
            self.log(f"LLM request to {model} ({len(prompt)} chars)")
            response = requests.post(
                llm_hostname,
                json=llm_body,
                timeout=timeout
            )
            response.raise_for_status()
            result = response.json()["response"]
            self.log("LLM call successful")
            return result
        except requests.exceptions.ConnectionError:
            print("[ERROR] Cannot connect to Ollama. Is it running? (ollama serve)")
            print("[ERROR] Start Ollama with: ollama serve")
            return None
        except requests.exceptions.Timeout:
            print(f"[ERROR] LLM request timed out. Model {model} may be too large or slow.")
            return None
        except Exception as e:
            print(f"[ERROR] LLM call failed: {e}")
            return None
    
    def read_docs_context(self, docs_dir: str) -> Dict[str, str]:
        """Read hand-written documentation files as ground truth context"""
        docs = {}
        readme_path = Path(docs_dir) / "README"
        if not readme_path.exists():
            self.log(f"README docs directory not found: {readme_path}")
            return docs
        
        key_docs = [
            'quick-start.md', 'basic-configuration.md', 'controller.md',
            'atis.md', 'sectors.md', 'event-handlers.md', 'exports.md',
            'advanced-configuration.md', 'map-markers.md', 'notifier.md',
            'platforms.md', 'installation.md',
        ]
        
        for filename in key_docs:
            filepath = readme_path / filename
            if filepath.exists():
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        docs[filename] = f.read()
                    self.log(f"Loaded doc: {filename}")
                except Exception as e:
                    self.log(f"Could not read {filepath}: {e}")
        return docs
    
    def build_api_cheatsheet(self, parsed_files: List[FileData]) -> str:
        """Build compact API reference string from parsed method data"""
        PUBLIC_HOUND_FUNCTIONS = {
            'HOUND.getInstance', 'HOUND.setMgrsPresicion',
            'HOUND.showExtendedInfo', 'HOUND.addEventHandler',
            'HOUND.removeEventHandler'
        }
        
        # Internal methods that should NOT appear in the public cheatsheet
        INTERNAL_METHODS = {
            'HoundElint.runCycle', 'HoundElint.updateSystemState',
            'HoundElint:purgeRadioMenu', 'HoundElint:populateRadioMenu',
            'HoundElint:onHoundInternalEvent', 'HoundElint:printDebugging',
        }
        
        lines = []
        for file_data in parsed_files:
            filename = file_data.filename
            if not (filename.startswith('800 -') or filename.startswith('801 -') or filename.startswith('000 -')):
                continue
            
            for func in file_data.functions:
                if not func.signature:
                    continue
                func_name = func.signature['name']
                
                is_public = (func_name.startswith('HoundElint') or
                            func_name in PUBLIC_HOUND_FUNCTIONS)
                if not is_public:
                    continue
                if func.is_local and func_name.startswith('HOUND.'):
                    continue
                if func_name in INTERNAL_METHODS:
                    continue
                
                params = func.signature.get('params', [])
                params_str = ', '.join(params)
                desc = ' '.join(func.description).strip() if func.description else ''
                
                line = f"- `{func_name}({params_str})`"
                if desc:
                    line += f" — {desc}"
                
                if func.params:
                    param_info = []
                    for p in func.params:
                        ptype = p.get('type', 'any').replace('type=', '')
                        param_info.append(f"{p['name']}:{ptype}")
                    line += f"  [{', '.join(param_info)}]"
                
                if func.returns:
                    ret_type = func.returns[0].get('type', '').replace('type=', '')
                    if ret_type:
                        line += f" → {ret_type}"
                
                lines.append(line)
        
        # Add key enums
        lines.append("")
        lines.append("**Enums:**")
        for file_data in parsed_files:
            for table_doc in file_data.tables:
                table_name = None
                if table_doc.signature:
                    table_name = table_doc.signature['name']
                elif table_doc.tags.get('table'):
                    table_name = table_doc.tags['table']
                
                if table_name in ('HOUND.MARKER', 'HOUND.EVENTS'):
                    vals = [f['name'] for f in table_doc.fields]
                    lines.append(f"- `{table_name}`: {', '.join(vals)}")
        
        return '\n'.join(lines)
    
    def build_categorized_api_reference(self, parsed_files: List[FileData]) -> str:
        """Build categorized API reference with method tables — deterministic, no LLM needed.
        
        Merges the categorization strength of the old api-index into the integration guide.
        """
        PUBLIC_HOUND_FUNCTIONS = {
            'HOUND.getInstance', 'HOUND.setMgrsPresicion',
            'HOUND.showExtendedInfo', 'HOUND.addEventHandler',
            'HOUND.removeEventHandler'
        }
        INTERNAL_METHODS = {
            'HoundElint.runCycle', 'HoundElint.updateSystemState',
            'HoundElint:purgeRadioMenu', 'HoundElint:populateRadioMenu',
            'HoundElint:onHoundInternalEvent', 'HoundElint:printDebugging',
        }
        
        # Deterministic category mapping by method short name
        CATEGORY_RULES = [
            ('Instance Management', {
                'create', 'destroy', 'getId', 'getCoalition', 'setCoalition',
                'systemOn', 'systemOff', 'isRunning', 'onScreenDebug',
            }),
            ('Platform Management', {
                'addPlatform', 'removePlatform', 'countPlatforms', 'listPlatforms',
            }),
            ('Detection & Contacts', {
                'countContacts', 'countActiveContacts', 'countPreBriefedContacts',
                'preBriefedContact', 'markDeadContact', 'AlertOnLaunch', 'countSites',
            }),
            ('Sector Management', {
                'addSector', 'removeSector', 'updateSectorSettings', 'listSectors',
                'getSectors', 'countSectors', 'getSector', 'getZone', 'setZone',
                'removeZone', 'updateSectorMembership',
            }),
            ('Controller', {
                'enableController', 'disableController', 'removeController',
                'configureController', 'getControllerFreq', 'getControllerState',
                'transmitOnController',
            }),
            ('ATIS', {
                'enableAtis', 'disableAtis', 'removeAtis', 'configureAtis',
                'getAtisFreq', 'reportEWR', 'getAtisState', 'setAtisUpdateInterval',
            }),
            ('Notifier', {
                'enableNotifier', 'disableNotifier', 'removeNotifier',
                'configureNotifier', 'getNotifierFreq', 'getNotifierState',
                'transmitOnNotifier',
            }),
            ('Map Markers', {
                'enableMarkers', 'disableMarkers', 'enableSiteMarkers',
                'disableSiteMarkers', 'setMarkerType',
            }),
            ('Settings & Configuration', {
                'enableText', 'disableText', 'enableTTS', 'disableTTS',
                'enableAlerts', 'disableAlerts', 'setCallsign', 'getCallsign',
                'setTransmitter', 'removeTransmitter', 'setTimerInterval',
                'enablePlatformPosErrors', 'disablePlatformPosErrors',
                'getCallsignOverride', 'setCallsignOverride',
                'getBDA', 'enableBDA', 'disableBDA',
                'getNATO', 'enableNATO', 'disableNATO',
                'getAlertOnLaunch', 'setAlertOnLaunch', 'useNATOCallsignes',
                'setRadioMenuParent',
            }),
            ('Event System', {
                'onHoundEvent', 'onEvent', 'defaultEventHandler',
            }),
            ('Data Export', {
                'getContacts', 'getSites', 'dumpIntelBrief',
            }),
        ]
        
        # Extract public methods
        all_methods = []
        for file_data in parsed_files:
            filename = file_data.filename
            if not (filename.startswith('800 -') or filename.startswith('801 -') or filename.startswith('000 -')):
                continue
            for func in file_data.functions:
                if not func.signature:
                    continue
                func_name = func.signature['name']
                is_public = (func_name.startswith('HoundElint') or
                            func_name in PUBLIC_HOUND_FUNCTIONS)
                if not is_public:
                    continue
                if func.is_local and func_name.startswith('HOUND.'):
                    continue
                if func_name in INTERNAL_METHODS:
                    continue
                all_methods.append(func)
        
        # Categorize each method
        categorized = {cat: [] for cat, _ in CATEGORY_RULES}
        categorized['Global Utilities'] = []
        
        for func in all_methods:
            func_name = func.signature['name']
            # HOUND.* goes to Global Utilities
            if func_name in PUBLIC_HOUND_FUNCTIONS:
                categorized['Global Utilities'].append(func)
                continue
            # Get short name after : or .
            short = func_name.split(':')[-1].split('.')[-1]
            placed = False
            for cat, methods_set in CATEGORY_RULES:
                if short in methods_set:
                    categorized[cat].append(func)
                    placed = True
                    break
            if not placed:
                categorized['Settings & Configuration'].append(func)
        
        # Build markdown
        lines = []
        for cat, _ in CATEGORY_RULES:
            funcs = categorized[cat]
            if not funcs:
                continue
            lines.append(f"### {cat}")
            lines.append("")
            lines.append("| Method | Parameters | Returns | Description |")
            lines.append("|--------|------------|---------|-------------|")
            for func in funcs:
                func_name = func.signature['name']
                # Format params
                if func.params:
                    param_strs = []
                    for p in func.params:
                        ptype = p.get('type', '').replace('type=', '').replace('?', '') or 'any'
                        param_strs.append(f"`{p['name']}` ({ptype})")
                    params_str = ", ".join(param_strs)
                else:
                    params_str = "—"
                # Format returns
                if func.returns:
                    ret = func.returns[0].get('type', '').replace('type=', '') or '—'
                else:
                    ret = "—"
                # Description
                desc = ' '.join(func.description).strip() if func.description else ''
                if desc:
                    desc = desc[0].upper() + desc[1:]
                    if len(desc) > 80:
                        desc = desc[:77] + "..."
                    desc = desc.replace("|", "\\|")
                else:
                    desc = "—"
                lines.append(f"| `{func_name}()` | {params_str} | {ret} | {desc} |")
            lines.append("")
        
        # Global Utilities
        if categorized['Global Utilities']:
            lines.append("### Global Utilities")
            lines.append("")
            lines.append("| Method | Parameters | Returns | Description |")
            lines.append("|--------|------------|---------|-------------|")
            for func in categorized['Global Utilities']:
                func_name = func.signature['name']
                if func.params:
                    param_strs = []
                    for p in func.params:
                        ptype = p.get('type', '').replace('type=', '').replace('?', '') or 'any'
                        param_strs.append(f"`{p['name']}` ({ptype})")
                    params_str = ", ".join(param_strs)
                else:
                    params_str = "—"
                if func.returns:
                    ret = func.returns[0].get('type', '').replace('type=', '') or '—'
                else:
                    ret = "—"
                desc = ' '.join(func.description).strip() if func.description else ''
                if desc:
                    desc = desc[0].upper() + desc[1:]
                    if len(desc) > 80:
                        desc = desc[:77] + "..."
                    desc = desc.replace("|", "\\|")
                else:
                    desc = "—"
                lines.append(f"| `{func_name}()` | {params_str} | {ret} | {desc} |")
            lines.append("")
        
        # Enums
        lines.append("### Enums")
        lines.append("")
        for file_data in parsed_files:
            for table_doc in file_data.tables:
                table_name = None
                if table_doc.signature:
                    table_name = table_doc.signature['name']
                elif table_doc.tags.get('table'):
                    table_name = table_doc.tags['table']
                if table_name in ('HOUND.MARKER', 'HOUND.EVENTS'):
                    vals = [f['name'] for f in table_doc.fields]
                    lines.append(f"- `{table_name}`: {', '.join(vals)}")
        lines.append("")
        
        return '\n'.join(lines)
    
    def extract_valid_methods(self, parsed_files: List[FileData]) -> set:
        """Extract set of valid method names from parsed files"""
        methods = set()
        for file_data in parsed_files:
            for func in file_data.functions:
                if func.signature:
                    name = func.signature['name']
                    methods.add(name)
                    if ':' in name:
                        methods.add(name.replace(':', '.'))
                    elif '.' in name:
                        methods.add(name.replace('.', ':'))
        return methods
    
    def validate_generated_code(self, code: str, valid_methods: set) -> Tuple[bool, List[str]]:
        """Validate that generated Lua code only uses real API methods.
        Returns (is_valid, list_of_issues)"""
        issues = []
        calls = re.findall(r'((?:HoundElint|HOUND)[.:]\w+)\s*[\(\{]', code)
        
        for call in set(calls):
            if call not in valid_methods:
                issues.append(f"Unknown method: {call}")
        
        return len(issues) == 0, issues
    
    def _extract_code_blocks(self, docs: Dict[str, str]) -> str:
        """Extract Lua code blocks from documentation as ground truth examples"""
        blocks = []
        for filename, content in docs.items():
            code_blocks = re.findall(r'```lua\n(.*?)```', content, re.DOTALL)
            for block in code_blocks[:3]:
                block = block.strip()
                if len(block) > 30 and ('HoundElint' in block or 'HOUND.' in block):
                    blocks.append(f"-- From {filename}:\n{block}")
        return '\n\n'.join(blocks[:15])
    
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
    
    def _legacy_generate_api_index_with_llm(self, parsed_files, model="llama3.2", docs_dir=None):
        """REMOVED — functionality merged into generate_llm_integration_guide via
        build_categorized_api_reference (deterministic, no LLM needed).
        Kept as stub for reference. Use --generate-integration-guide instead.
        """
        raise NotImplementedError("Use --generate-integration-guide instead of --generate-api-index")

    def _legacy_generate_api_index_skeleton(self, parsed_files):
        """REMOVED — see build_categorized_api_reference"""
        raise NotImplementedError("Use build_categorized_api_reference instead")

    def _original_generate_api_index_with_llm(self, parsed_files: List[FileData], model: str = "llama3.2",
                                     docs_dir: str = None) -> str:
        """DEPRECATED: Generate one-page API index using local LLM for organization and summarization
        
        Replaced by build_categorized_api_reference() which is deterministic and does not need LLM.
        """
        self.log("Starting API index generation with LLM assistance")
        
        # Load hand-written docs as ground truth for example generation
        self._docs_context = {}
        if docs_dir:
            self._docs_context = self.read_docs_context(docs_dir)
        self._valid_methods = self.extract_valid_methods(parsed_files)
        
        # Public HOUND.* functions that mission builders use (not internal/developer API)
        PUBLIC_HOUND_FUNCTIONS = {
            'HOUND.getInstance',
            'HOUND.setMgrsPresicion',
            'HOUND.showExtendedInfo',
            'HOUND.addEventHandler',
            'HOUND.removeEventHandler'
        }
        
        # Step 1: Extract public methods from HoundElint (mission builder API only)
        methods = []
        
        for file_data in parsed_files:
            filename = file_data.filename
            
            # Include HoundElint files (800, 801) and global files (000)
            if filename.startswith('800 -') or filename.startswith('801 -') or filename.startswith('000 -'):
                for func in file_data.functions:
                    if func.signature:
                        func_name = func.signature['name']
                        
                        # Include HoundElint methods (public API)
                        if func_name.startswith('HoundElint'):
                            methods.append({
                                "name": func_name,
                                "params": [{"name": p["name"], "type": p.get("type", "any")} 
                                          for p in func.params],
                                "returns": [{"type": r.get("type", "any")} for r in func.returns],
                                "description": " ".join(func.description) if func.description else "",
                                "is_local": func.is_local
                            })
                        
                        # Include only whitelisted HOUND.* functions (public utilities)
                        elif func_name in PUBLIC_HOUND_FUNCTIONS and not func.is_local:
                            methods.append({
                                "name": func_name,
                                "params": [{"name": p["name"], "type": p.get("type", "any")} 
                                          for p in func.params],
                                "returns": [{"type": r.get("type", "any")} for r in func.returns],
                                "description": " ".join(func.description) if func.description else "",
                                "is_local": func.is_local
                            })
        
        self.log(f"Extracted {len(methods)} public methods")
        
        if not methods:
            return "# API Index\n\nNo public methods found."
        
        # Step 2: Ask LLM to categorize methods
        self.log("Asking LLM to categorize methods...")
        
        method_names = [m["name"] for m in methods]
        
        categorization_prompt = f"""You are analyzing the Hound ELINT PUBLIC API for DCS World mission builders.

These are PUBLIC methods for everyday mission builders (NOT internal/developer functions).

Here are all the public method names:
{json.dumps(method_names, indent=2)}

Organize these methods into logical functional categories. Use these categories:
- Instance Management (create, destroy, systemOn, systemOff, etc.)
- Platform Management (add/remove ELINT platforms)
- Detection & Contacts (radar contacts, sites, pre-briefed contacts)
- Sector Management (geographic organization)
- Controller (interactive radio menu system)
- ATIS (automated broadcasts)
- Notifier (alert system)
- Map Markers (F10 visual feedback)
- Settings & Configuration (timers, text/TTS, callsigns, etc.)
- Event System (custom script hooks)
- Data Export (getContacts, getSites, CSV export)
- Global Utilities (HOUND.getInstance, HOUND.addEventHandler, etc.)

Return ONLY valid JSON in this exact format (no markdown formatting, no explanations):
{{
  "Instance Management": ["HoundElint:create", "HoundElint:destroy", ...],
  "Platform Management": ["HoundElint:addPlatform", ...],
  ...
}}
"""
        
        categories_response = self.call_local_llm(categorization_prompt, model)
        
        if not categories_response:
            print("[ERROR] Failed to get categorization from LLM")
            return self.generate_api_index_skeleton(parsed_files)
        
        # Try to parse JSON from response (handle if LLM adds markdown formatting)
        try:
            # Remove potential markdown code blocks
            json_str = categories_response.strip()
            if json_str.startswith("```"):
                json_str = re.sub(r'^```[a-z]*\n', '', json_str)
                json_str = re.sub(r'\n```$', '', json_str)
            
            categories = json.loads(json_str)
            self.log(f"Successfully categorized methods into {len(categories)} categories")
        except json.JSONDecodeError as e:
            print(f"[ERROR] Failed to parse LLM JSON response: {e}")
            print(f"Response was: {categories_response[:200]}...")
            return self.generate_api_index_skeleton(parsed_files)
        
        # Step 3: Generate documentation sections
        lines = [
            "# API Index - Quick Reference",
            "",
            "Complete listing of all **public Hound methods** for mission builders, organized by category.",
            "",
            "This is the **Public API** for everyday mission builders. For internal/developer functions, see [Developer API](../dev/).",
            "",
            "*Generated with LLM assistance*",
            "",
            "---",
            "",
            "## Table of Contents",
            ""
        ]
        
        # Add TOC
        for category in categories.keys():
            anchor = re.sub(r'[^a-zA-Z0-9]+', '-', category.lower()).strip('-')
            lines.append(f"- [{category}](#{anchor})")
        
        lines.append("")
        lines.append("---")
        lines.append("")
        
        # Step 4: Generate each category section
        for category, method_names_in_category in categories.items():
            self.log(f"Generating section: {category}")
            
            # Get full method data for this category
            category_methods = [m for m in methods if m["name"] in method_names_in_category]
            
            if not category_methods:
                continue
            
            lines.append(f"## {category}")
            lines.append("")
            
            # Generate table with proper formatting (skip LLM for tables - it hallucinates)
            lines.append("| Method | Parameters | Returns | Description |")
            lines.append("|--------|------------|---------|-------------|")
            
            for method in category_methods:
                # Clean up types
                def clean_type(t):
                    # Remove LDOC type markers and clean up
                    t = str(t).replace("type=", "").replace("?", "").strip()
                    # Map common types to clean names
                    type_map = {
                        "tab": "table",
                        "int": "int",
                        "bool": "bool",
                        "Bool": "bool",
                        "Int": "int",
                        "string": "string",
                        "number": "number"
                    }
                    return type_map.get(t, t) if t else "-"
                
                # Format parameters with optional markers
                if method["params"]:
                    param_strs = []
                    for p in method["params"]:
                        param_name = p['name']
                        param_type = clean_type(p['type'])
                        # Check if parameter name suggests it's optional
                        is_opt = 'opt' in str(p.get('description', '')).lower() or param_name == 'opt'
                        if is_opt or param_type == "-":
                            param_strs.append(f"`{param_name}` ({param_type}, opt)")
                        else:
                            param_strs.append(f"`{param_name}` ({param_type})")
                    params_str = ", ".join(param_strs)
                else:
                    params_str = "-"
                
                # Format returns
                if method["returns"]:
                    returns_str = clean_type(method["returns"][0]["type"])
                else:
                    returns_str = "-"
                
                # Clean description
                desc = method["description"].strip()
                if desc:
                    # Capitalize first letter
                    desc = desc[0].upper() + desc[1:] if desc else desc
                    # Add period if missing
                    if desc and not desc.endswith('.') and not desc.endswith('...'):
                        desc += '.'
                else:
                    desc = "No description available."
                
                # Truncate if too long
                if len(desc) > 80:
                    desc = desc[:77] + "..."
                
                # Escape pipes in description
                desc = desc.replace("|", "\\|")
                
                lines.append(f"| `{method['name']}()` | {params_str} | {returns_str} | {desc} |")
            
            lines.append("")
            
            # Ask LLM for example code for this category
            # Build detailed method info including types and descriptions
            method_details = []
            for m in category_methods[:8]:
                sig_parts = []
                if m["params"]:
                    for p in m["params"]:
                        ptype = p.get('type', 'any').replace('type=', '').replace('?', '')
                        sig_parts.append(f"{p['name']}:{ptype}")
                sig = f"  {m['name']}({', '.join(sig_parts)})"
                desc = m.get('description', '').strip()
                if desc:
                    sig += f"  -- {desc}"
                method_details.append(sig)
            
            # Find ground truth example from hand-written docs for this category
            category_doc_map = {
                'Instance Management': 'basic-configuration.md',
                'Platform Management': 'basic-configuration.md',
                'Detection & Contacts': 'basic-configuration.md',
                'Sector Management': 'sectors.md',
                'Controller': 'controller.md',
                'ATIS': 'atis.md',
                'Notifier': 'notifier.md',
                'Map Markers': 'basic-configuration.md',
                'Settings & Configuration': 'advanced-configuration.md',
                'Event System': 'event-handlers.md',
                'Data Export': 'exports.md',
                'Global Utilities': 'advanced-configuration.md',
            }
            ground_truth_section = ""
            doc_file = category_doc_map.get(category, '')
            if doc_file and doc_file in self._docs_context:
                code_blocks = re.findall(r'```lua\n(.*?)```',
                                        self._docs_context[doc_file], re.DOTALL)
                # Find a code block that uses methods from this category
                for block in code_blocks[:5]:
                    block = block.strip()
                    if any(m['name'].split(':')[-1] in block or
                           m['name'].split('.')[-1] in block
                           for m in category_methods[:3]):
                        ground_truth_section = f"""
CORRECT example from official documentation (follow this pattern exactly):
```lua
{block}
```"""
                        break
                if not ground_truth_section and code_blocks:
                    ground_truth_section = f"""
CORRECT example from official documentation (follow this pattern exactly):
```lua
{code_blocks[0].strip()}
```"""
            
            example_prompt = f"""Generate a practical Lua code example for the "{category}" category of Hound ELINT (DCS World radar detection).

Methods available (use ONLY these, with their parameter types):
{chr(10).join(method_details)}
{ground_truth_section}

STRICT RULES - violations will make the example WRONG:
- HoundElint:create() takes coalition.side.BLUE or coalition.side.RED (or a unit name string)
- addPlatform() takes ONE argument: a DCS unit name string like "ELINT_C130"
- enableController/enableAtis take optional sectorName string, then settings table: {{freq="251.000", modulation="AM"}}
- Marker types are enums: HOUND.MARKER.CIRCLE, HOUND.MARKER.POLYGON, HOUND.MARKER.POINT, HOUND.MARKER.NONE
- Event handlers are objects with onHoundEvent(event) method, registered via HOUND.addEventHandler(handler)
- HOUND.getInstance() takes a number (instance ID), not a string
- preBriefedContact() takes a SAM unit/group name, NOT an ELINT platform name
- Do NOT invent methods or parameters not listed above

Show 2-4 methods. Keep concise (5-10 lines). Return ONLY lua code in a markdown code block."""
            
            example_response = self.call_local_llm(example_prompt, model)
            
            if example_response:
                # Clean up response - extract code block
                example_code = example_response.strip()
                code_match = re.search(r'```lua\n(.*?)```', example_code, re.DOTALL)
                if code_match:
                    example_code = code_match.group(1).strip()
                elif example_code.startswith("```"):
                    example_code = re.sub(r'^```\w*\n?', '', example_code)
                    example_code = re.sub(r'\n?```$', '', example_code)
                
                # Validate generated code against real API
                is_valid, issues = self.validate_generated_code(example_code, self._valid_methods)
                if not is_valid:
                    self.log(f"Example validation issues for '{category}': {issues}")
                
                lines.append("**Example:**")
                lines.append("")
                lines.append(f"```lua\n{example_code}\n```")
                lines.append("")
            
            lines.append("---")
            lines.append("")
        
        # Add footer
        lines.extend([
            "## See Also",
            "",
            "- **[System Architecture](architecture.md)** - How components work together",
            "- **[Quick Start](quick-start.md)** - Get started with Hound",
            "- **[Full API Documentation](../HOUND_API_REFERENCE.md)** - Complete public API reference",
            "- **[Developer API](../dev/)** - Internal functions for advanced users",
            ""
        ])
        
        return '\n'.join(lines)
    
    def generate_api_index_skeleton(self, parsed_files: List[FileData]) -> str:
        """Generate basic API index skeleton without LLM (fallback)
        
        Focuses on PUBLIC API for mission builders, excludes internal developer functions.
        """
        # Public HOUND.* functions that mission builders use
        PUBLIC_HOUND_FUNCTIONS = {
            'HOUND.getInstance',
            'HOUND.setMgrsPresicion',
            'HOUND.showExtendedInfo',
            'HOUND.addEventHandler',
            'HOUND.removeEventHandler'
        }
        
        lines = [
            "# API Index - Quick Reference",
            "",
            "Complete listing of all public Hound methods.",
            "",
            "*Note: LLM generation failed, showing basic skeleton*",
            "",
            "---",
            "",
        ]
        
        # List HoundElint methods
        lines.append("## HoundElint Methods (Public API)")
        lines.append("")
        
        for file_data in parsed_files:
            filename = file_data.filename
            
            if filename.startswith('800 -') or filename.startswith('801 -'):
                for func in file_data.functions:
                    if func.signature and not func.is_local:
                        func_name = func.signature['name']
                        if func_name.startswith('HoundElint'):
                            params = ', '.join(func.signature.get('params', []))
                            lines.append(f"- `{func_name}({params})`")
        
        lines.append("")
        
        # List public HOUND.* utility functions
        lines.append("## HOUND Global Functions (Public Utilities)")
        lines.append("")
        
        for file_data in parsed_files:
            filename = file_data.filename
            
            if filename.startswith('000 -'):
                for func in file_data.functions:
                    if func.signature and not func.is_local:
                        func_name = func.signature['name']
                        if func_name in PUBLIC_HOUND_FUNCTIONS:
                            params = ', '.join(func.signature.get('params', []))
                            lines.append(f"- `{func_name}({params})`")
        
        lines.append("")
        lines.append("---")
        lines.append("")
        lines.append("## See Also")
        lines.append("")
        lines.append("- **[Full API Documentation](../HOUND_API_REFERENCE.md)** - Complete reference")
        lines.append("- **[Developer API](../dev/)** - Internal functions for advanced users")
        lines.append("")
        
        return '\n'.join(lines)
    
    def generate_llm_integration_guide(self, parsed_files: List[FileData],
                                        docs_dir: str, model: str,
                                        generated_api_doc: str = "") -> str:
        """Generate comprehensive LLM-optimized integration guide with validated examples.
        
        This document is designed to be self-contained: an LLM reading only this file
        should be able to correctly integrate Hound into a DCS mission.
        
        Args:
            generated_api_doc: The freshly-generated HOUND_API_REFERENCE.md content.
                              This is the most authoritative source since it's parsed
                              directly from current source files.
        """
        self.log("Starting LLM integration guide generation")
        
        # Step 1: Build context
        # The generated API doc is PRIMARY — it comes straight from the source code
        api_cheatsheet = self.build_api_cheatsheet(parsed_files)
        categorized_api = self.build_categorized_api_reference(parsed_files)
        docs = self.read_docs_context(docs_dir)
        valid_methods = self.extract_valid_methods(parsed_files)
        ground_truth = self._extract_code_blocks(docs)
        
        self.log(f"API cheatsheet: {len(api_cheatsheet)} chars")
        self.log(f"Categorized API reference: {len(categorized_api)} chars")
        self.log(f"Generated API doc: {len(generated_api_doc)} chars")
        self.log(f"Ground truth examples: {len(ground_truth)} chars")
        self.log(f"Valid methods: {len(valid_methods)}")
        
        # Step 2: Define integration scenarios
        scenarios = [
            {
                "title": "Minimal Setup — Map Markers Only",
                "desc": "Simplest possible Hound setup. Create instance for Blue coalition, "
                        "add 2 ELINT platforms by unit name, enable polygon map markers, "
                        "activate the system. No voice, no sectors. Wrap in do...end block.",
            },
            {
                "title": "Basic Setup with Voice Communications",
                "desc": "Blue coalition with 3 platforms. Enable Controller on 251.000 AM with "
                        "text messages enabled. Enable ATIS on 253.000 AM. Enable BDA and "
                        "launch alerts. Pre-brief 2 known SAM sites with custom code names. "
                        "Use HOUND.MARKER.CIRCLE for markers. Wrap in do...end block.",
            },
            {
                "title": "Multi-Sector Mission with Zones",
                "desc": "Blue coalition with 4 platforms. Create 2 named sectors: 'North' and "
                        "'South'. Set geographic zones for each using setZone(). Each sector "
                        "gets its own Controller and ATIS on different frequencies with male/"
                        "female voices. Set custom callsigns per sector. Add a global Notifier "
                        "on guard freq 243.000 AM. Enable text for all sectors. Wrap in do...end.",
            },
            {
                "title": "Event Handlers — Custom Mission Logic",
                "desc": "Set up basic Hound instance. Create an event handler TABLE (not function) "
                        "with an onHoundEvent METHOD. Register it with HOUND.addEventHandler(). "
                        "Handle RADAR_NEW (announce via trigger.action.outText), RADAR_DESTROYED "
                        "(count kills), and SITE_REMOVED (check mission objectives). "
                        "Always filter by event.coalition. Show the handler table pattern from "
                        "the official docs.",
            },
            {
                "title": "Data Export and Periodic Intelligence",
                "desc": "Set up Hound instance. Show how to: "
                        "(1) call getSites() — it returns {sam={count=N, sites={...}}, ewr={count=N, sites={...}}}. "
                        "Iterate with: for _, site in ipairs(data.sam.sites) do ... end. "
                        "Access site.name, site.Type, site.emitters. For each emitter: "
                        "emitter.typeName, emitter.LL.lat, emitter.LL.lon, emitter.accuracy. "
                        "IMPORTANT: check 'if emitter.pos then' before accessing LL. "
                        "(2) Call dumpIntelBrief() for CSV export. "
                        "(3) Set up periodic export using DCS timer: "
                        "timer.scheduleFunction(fn, nil, timer.getTime() + interval). "
                        "NOTE: timer.scheduleFunction takes (function, argument, absoluteTime). "
                        "Use timer.getTime() + seconds for the time parameter. "
                        "Put the getSites iteration in a scheduled function (not immediately after systemOn, "
                        "since detection takes 1-2 minutes). Wrap in do...end block.",
            },
        ]
        
        # Step 3: Generate each scenario
        generated = []
        for scenario in scenarios:
            self.log(f"Generating scenario: {scenario['title']}")
            
            # Build the prompt with generated API doc as primary reference
            api_context = ""
            if generated_api_doc:
                api_context = f"""PRIMARY API REFERENCE (generated from source code — this is the authoritative source):
{generated_api_doc}

"""
            
            prompt = f"""You are writing a DCS World mission Lua script using the Hound ELINT radar detection system.

{api_context}API METHOD SIGNATURES (compact quick-reference):
{api_cheatsheet}

CORRECT USAGE PATTERNS FROM OFFICIAL DOCUMENTATION:
{ground_truth}

TASK: Write a complete, working Lua script for: {scenario['desc']}

STRICT RULES:
1. Use ONLY methods listed in the API reference above
2. Follow the EXACT patterns shown in the official examples
3. Coalition parameter is coalition.side.BLUE or coalition.side.RED
4. Platform names are DCS unit name strings like "ELINT_C130", "ELINT_Tower"
5. enableController/enableAtis accept optional sector name as first arg, settings table as second
6. Settings table format: {{freq = "251.000", modulation = "AM", gender = "male"}}
7. Marker types use enum: HOUND.MARKER.CIRCLE, HOUND.MARKER.POLYGON, etc.
8. Event handlers are TABLE objects with onHoundEvent(event) method, registered via HOUND.addEventHandler()
9. addPlatform() takes ONE argument: the DCS unit name string
10. HOUND.getInstance() takes a number, not a string
11. preBriefedContact() takes a SAM unit/group name and optional code name string
12. Wrap the main script in do...end block
13. Include clear inline comments
14. Do NOT invent methods or parameters not in the API reference

Return ONLY the Lua code in a markdown code block. No explanations outside the code."""

            response = self.call_local_llm(prompt, model)
            
            if not response:
                self.log(f"LLM failed for scenario: {scenario['title']}")
                continue
            
            # Extract code
            code = response.strip()
            code_match = re.search(r'```lua\n(.*?)```', code, re.DOTALL)
            if code_match:
                code = code_match.group(1).strip()
            elif code.startswith('```'):
                code = re.sub(r'^```\w*\n?', '', code)
                code = re.sub(r'\n?```$', '', code)
            
            # Validate
            is_valid, issues = self.validate_generated_code(code, valid_methods)
            
            if not is_valid:
                self.log(f"Validation issues in '{scenario['title']}': {issues}")
                # Attempt fix
                fix_prompt = f"""Fix this Lua code. These method calls do NOT exist: {', '.join(issues)}

```lua
{code}
```

VALID METHODS (use ONLY these):
{api_cheatsheet}

Return ONLY the corrected Lua code in a markdown code block."""
                
                fix_response = self.call_local_llm(fix_prompt, model)
                if fix_response:
                    fix_match = re.search(r'```lua\n(.*?)```', fix_response.strip(), re.DOTALL)
                    if fix_match:
                        code = fix_match.group(1).strip()
                    is_valid, issues = self.validate_generated_code(code, valid_methods)
                    if not is_valid:
                        self.log(f"Still invalid after fix: {issues}")
            
            generated.append({
                "title": scenario['title'],
                "desc": scenario['desc'],
                "code": code,
                "valid": is_valid,
                "issues": issues if not is_valid else []
            })
        
        # Step 4: Validation pass — ask LLM to integrate Hound using ONLY the generated content
        self.log("Running documentation quality validation...")
        
        compact_guide = self._assemble_guide_body(api_cheatsheet, generated)
        
        validation_prompt = f"""You are a DCS World mission builder. Using ONLY the documentation below, write a Lua script that:
1. Creates a Hound ELINT instance for Blue coalition
2. Adds 3 ELINT platforms
3. Enables a Controller with voice on 251.000 AM
4. Enables map markers with CIRCLE type
5. Adds a pre-briefed SAM site
6. Activates the system

DOCUMENTATION:
{compact_guide[:6000]}

Return ONLY the Lua code. No explanations."""

        validation_response = self.call_local_llm(validation_prompt, model)
        validation_result = ""
        
        if validation_response:
            val_code = validation_response.strip()
            val_match = re.search(r'```lua\n(.*?)```', val_code, re.DOTALL)
            if val_match:
                val_code = val_match.group(1).strip()
            elif val_code.startswith('```'):
                val_code = re.sub(r'^```\w*\n?', '', val_code)
                val_code = re.sub(r'\n?```$', '', val_code)
            
            is_valid, issues = self.validate_generated_code(val_code, valid_methods)
            if is_valid:
                validation_result = (
                    "**PASSED** — An LLM successfully wrote correct integration code "
                    "using only this guide as context."
                )
                self.log("Validation PASSED")
            else:
                validation_result = (
                    f"**NEEDS REVIEW** — LLM-generated validation code had issues: "
                    f"{', '.join(issues)}. The documentation for these methods may need "
                    f"clarification."
                )
                self.log(f"Validation issues: {issues}")
        else:
            validation_result = "*Validation skipped: LLM call failed.*"
        
        # Step 5: Assemble final document
        return self._assemble_integration_guide(categorized_api, generated,
                                                 validation_result)
    
    def _assemble_guide_body(self, api_cheatsheet: str, scenarios: list) -> str:
        """Assemble guide body (for validation prompt context)"""
        lines = [
            "# Hound ELINT Integration Guide",
            "",
            "## API Reference",
            api_cheatsheet,
            "",
        ]
        for s in scenarios:
            lines.extend([f"## {s['title']}", "", f"```lua\n{s['code']}\n```", ""])
        return '\n'.join(lines)
    
    def _assemble_integration_guide(self, categorized_api: str, scenarios: list,
                                     validation_result: str) -> str:
        """Assemble the final integration guide document"""
        lines = [
            "# Hound ELINT — LLM Integration Guide",
            "",
            "Everything needed to integrate the Hound ELINT radar detection system into a "
            "DCS World mission. This document is self-contained — no other files required.",
            "",
            f"*Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*",
            "",
            "---",
            "",
            "## What is Hound ELINT?",
            "",
            "Hound is a radar detection and tracking system for DCS World. It detects enemy "
            "radar emitters using ELINT platforms (aircraft, ground stations), triangulates "
            "their positions, and provides intelligence via:",
            "",
            "- **F10 map markers** with uncertainty ellipses",
            "- **Voice radio** (TTS via SRS) — interactive Controller and automated ATIS",
            "- **Text messages** — in-game text popups",
            "- **Data exports** — Lua tables and CSV files",
            "",
            "**Key concepts:**",
            "",
            "| Concept | Description |",
            "|---------|-------------|",
            "| **Instance** | One Hound system per coalition (`HoundBlue`, `HoundRed`) |",
            "| **Platform** | DCS unit that collects radar signals (C-130, tower, etc.) |",
            "| **Contact** | Detected radar emitter with estimated position |",
            "| **Site** | Group of related radars (e.g., SA-6 with TR + SR) |",
            "| **Sector** | Geographic region with separate comms channels |",
            "| **Controller** | Interactive F10 radio menu for on-demand intel |",
            "| **ATIS** | Automated periodic threat broadcast |",
            "| **Notifier** | Alert broadcasts (new threats, launches, BDA) |",
            "",
            "---",
            "",
            "## Setup Requirements",
            "",
            "### Mission Editor Triggers",
            "",
            "**Trigger 1** (TYPE: ONCE, CONDITION: TIME MORE 1):",
            "1. DO SCRIPT FILE: `DCS-SimpleTextToSpeech.lua` *(only if using voice)*",
            "2. DO SCRIPT FILE: `HoundElint.lua`",
            "",
            "**Trigger 2** (TYPE: ONCE, CONDITION: TIME MORE 2):",
            "1. DO SCRIPT: *(your Hound configuration code)*",
            "",
            "### Mission Units",
            "",
            "Place at least 2 ELINT platform units (for triangulation):",
            "- Aircraft: C-130, C-17, EA-6B, EA-18G, RC-135, etc.",
            "- Ground: Comms Tower M (static object on high ground)",
            "- Use the exact **unit name** (not group name) when calling `addPlatform()`",
            "",
            "---",
            "",
            "## API Quick Reference",
            "",
            categorized_api,
            "",
            "---",
            "",
            "## Integration Examples",
            "",
        ]
        
        for i, s in enumerate(scenarios, 1):
            lines.append(f"### Example {i}: {s['title']}")
            lines.append("")
            lines.append("```lua")
            lines.append(s['code'])
            lines.append("```")
            lines.append("")
            if s.get('issues'):
                lines.append(f"> **Note:** Validation flagged: {', '.join(s['issues'])}")
                lines.append("")
            lines.append("---")
            lines.append("")
        
        # Common patterns
        lines.extend([
            "## Common Patterns and Pitfalls",
            "",
            "### Controller/ATIS Settings Table",
            "",
            "```lua",
            "local settings = {",
            '    freq = "251.000",        -- frequency string; comma-separated for multiple',
            '    modulation = "AM",       -- "AM" or "FM"; comma-separated if multiple freqs',
            '    gender = "male",         -- TTS voice gender: "male" or "female"',
            '    culture = "en-US",       -- TTS culture code',
            '    speed = 0,               -- TTS speed (-10 to +10 for STTS)',
            '    volume = "1.0"           -- TTS volume',
            "}",
            "",
            "-- Default sector:",
            'HoundInstance:enableController(settings)',
            "",
            "-- Named sector:",
            'HoundInstance:enableController("North", settings)',
            "```",
            "",
            "### Event Handler Pattern",
            "",
            "```lua",
            "-- Handler is a TABLE with an onHoundEvent METHOD",
            "MyHandler = {}",
            "function MyHandler:onHoundEvent(event)",
            "    if event.coalition ~= coalition.side.BLUE then return end",
            "    if event.id == HOUND.EVENTS.RADAR_NEW then",
            '        trigger.action.outText("New: " .. event.initiator:getName(), 10)',
            "    end",
            "end",
            "HOUND.addEventHandler(MyHandler)",
            "```",
            "",
            "### Export Data Iteration",
            "",
            "```lua",
            "local data = HoundInstance:getSites()",
            "-- Structure: data.sam.count, data.sam.sites[], data.ewr.count, data.ewr.sites[]",
            "for _, site in ipairs(data.sam.sites) do",
            '    env.info("Site: " .. site.name .. " Type: " .. site.Type)',
            "    for _, emitter in ipairs(site.emitters) do",
            "        if emitter.pos then",
            '            env.info(string.format("  %s at %.4f, %.4f (%s)",',
            "                emitter.typeName, emitter.LL.lat, emitter.LL.lon, emitter.accuracy))",
            "        end",
            "    end",
            "end",
            "```",
            "",
            "### Important Rules",
            "",
            "- `HoundElint:create()` takes `coalition.side.BLUE`/`RED` or a unit name string",
            "- `addPlatform()` takes **one** string: the exact DCS unit name",
            "- `setRadioMenuParent()` must be called **before** `enableController()`",
            "- Call `systemOn()` **after** all configuration",
            "- Marker types: `HOUND.MARKER.NONE`, `.SITE_ONLY`, `.POINT`, `.CIRCLE`, "
            "`.DIAMOND`, `.OCTAGON`, `.POLYGON`",
            "- At least 2 platforms recommended for triangulation",
            "- Platforms auto-removed if destroyed; can add dynamically during mission",
            "- Sector name `\"default\"` always exists; `\"all\"` applies settings globally",
            "",
            "---",
            "",
            "## Documentation Quality Check",
            "",
            validation_result,
            "",
            "---",
            "",
            "## Further Reading",
            "",
            "- `docs/README/quick-start.md` — Step-by-step setup guide",
            "- `docs/README/basic-configuration.md` — All basic options",
            "- `docs/README/controller.md` — Controller details",
            "- `docs/README/sectors.md` — Multi-sector setup",
            "- `docs/README/event-handlers.md` — Event system details",
            "- `docs/README/exports.md` — Data export formats",
            "- `docs/HOUND_API_REFERENCE.md` — Complete public API reference",
            "- `demo_mission/` — Ready-to-fly demo missions",
            "",
        ]
        )
        
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
        "--llm-host",
        default=None,
        help="Ollama host URL (default: auto-detect; respects OLLAMA_HOST env var)"
    )
    parser.add_argument(
        "--llm-model",
        default="qwen3:4b",
        help="Ollama model to use (default: qwen3:4b)"
    )
    parser.add_argument(
        "--llm-context",
        type=int,
        default=None,
        help="Context window size (num_ctx) for Ollama. If not set, uses the model default."
    )
    parser.add_argument(
        "--llm-timeout",
        type=int,
        default=300,
        help="Timeout in seconds for each LLM call (default: 300)"
    )
    parser.add_argument(
        "--use-large-model",
        action="store_true",
        help="Use qwen3:14b instead of default qwen3:4b (better quality, slower)"
    )
    parser.add_argument(
        "--skip-integration-guide",
        action="store_true",
        help="Skip LLM integration guide generation (only produce API reference markdown files)"
    )
    parser.add_argument(
        "--verbose", "-v", 
        action="store_true", 
        help="Enable verbose output"
    )
    
    args = parser.parse_args()
    
    # Initialize components
    parser_instance = LuaDocParser(verbose=args.verbose)
    generator = MarkdownGenerator(verbose=args.verbose, num_ctx=args.llm_context,
                                    llm_timeout=args.llm_timeout,
                                    llm_host=args.llm_host)
    
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
    
    # Generate public API documentation FIRST (used as context for integration guide)
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
    
    # Generate LLM integration guide (default, unless --skip-integration-guide or Ollama unavailable)
    if not args.skip_integration_guide:
        if not generator.check_ollama_available():
            print("[WARN] Ollama not available — skipping integration guide generation")
        else:
            if args.use_large_model:
                model = "qwen3:14b"
            else:
                model = args.llm_model
            
            print(f"Generating LLM integration guide with model: {model}")
            
            guide_doc = generator.generate_llm_integration_guide(
                parsed_files, args.public_output_dir, model,
                generated_api_doc=public_doc)
            guide_path = public_output_path / "README" / "llm-integration-guide.md"
            
            (public_output_path / "README").mkdir(parents=True, exist_ok=True)
            
            try:
                with open(guide_path, 'w', encoding='utf-8') as f:
                    f.write(guide_doc)
                print(f"\u2713 Generated LLM integration guide: {guide_path}")
            except Exception as e:
                print(f"[ERROR] Could not write integration guide: {e}")
                return 1
    
    if args.verbose:
        print("Documentation generation completed successfully!")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
