#!/usr/bin/env python3
"""Claude Code statusLine hook - multi-line hierarchical display.

Line 1: Model | Context bar + % | Token usage (used only)
Line 2: Branch | Directory (max 20ch) | Rate limits | Cost
Line 3: Agent / Worktree info (conditional)

Colors: threshold-based fixed ANSI (green <50%, yellow 50-79%, red >=80%).
"""
import json
import os
import subprocess
import sys
import time

data = json.load(sys.stdin)

BRAILLE = ' \u28c0\u28c4\u28e4\u28e6\u28f6\u28f7\u28ff'
R = '\033[0m'
DIM = '\033[2m'
BOLD = '\033[1m'
CYAN = '\033[36m'
SEP = f' {DIM}\u2502{R} '

GIT_CACHE = '/tmp/claude-statusline-git-branch'
GIT_CACHE_TTL = 5


def threshold_color(pct):
    if pct < 50:
        return '\033[32m'   # green
    if pct < 80:
        return '\033[33m'   # yellow
    return '\033[31m'       # red


def braille_bar(pct, width=6):
    pct = min(max(pct, 0), 100)
    level = pct / 100
    bar = ''
    for i in range(width):
        seg_start = i / width
        seg_end = (i + 1) / width
        if level >= seg_end:
            bar += BRAILLE[7]
        elif level <= seg_start:
            bar += BRAILLE[0]
        else:
            frac = (level - seg_start) / (seg_end - seg_start)
            bar += BRAILLE[min(int(frac * 7), 7)]
    return bar


def fmt(label, pct, width=6):
    p = round(pct)
    return f'{DIM}{label}{R} {threshold_color(pct)}{braille_bar(pct, width)}{R} {p}%'


def format_tokens(n):
    if n >= 1_000_000:
        v = n / 1_000_000
        return f'{v:.0f}M' if n % 1_000_000 == 0 else f'{v:.1f}M'
    if n >= 1_000:
        v = n / 1_000
        return f'{v:.0f}K' if n % 1_000 == 0 else f'{v:.1f}K'
    return str(n)


def get_git_branch(cwd):
    try:
        mtime = os.path.getmtime(GIT_CACHE)
        if time.time() - mtime < GIT_CACHE_TTL:
            with open(GIT_CACHE) as f:
                cached = f.read().strip()
                if cached:
                    return cached
    except OSError:
        pass
    try:
        result = subprocess.run(
            ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
            capture_output=True, text=True, timeout=2, cwd=cwd,
        )
        branch = result.stdout.strip() if result.returncode == 0 else ''
    except (subprocess.TimeoutExpired, FileNotFoundError):
        branch = ''
    try:
        with open(GIT_CACHE, 'w') as f:
            f.write(branch)
    except OSError:
        pass
    return branch


def shorten_path(path, max_len=20):
    home = os.path.expanduser('~')
    if path.startswith(home):
        path = '~' + path[len(home):]
    if len(path) <= max_len:
        return path
    parts = [p for p in path.split('/') if p]
    if len(parts) <= 1:
        return path
    prefix = '~/' if path.startswith('~') else '/'
    return prefix + '\u2026/' + parts[-1]


# --- Line 1: Model | Context | Tokens ---
model = data.get('model', {}).get('display_name', 'Claude')
line1 = [f'{BOLD}{model}{R}']

ctx_win = data.get('context_window', {})
ctx_pct = ctx_win.get('used_percentage')
if ctx_pct is not None:
    line1.append(fmt('ctx', ctx_pct))
    total_in = ctx_win.get('total_input_tokens', 0)
    total_out = ctx_win.get('total_output_tokens', 0)
    used_tokens = total_in + total_out
    if used_tokens > 0:
        line1.append(f'{DIM}{format_tokens(used_tokens)}{R}')

# --- Line 2: Branch | Dir | Rate limits | Cost ---
line2 = []

cwd = data.get('cwd') or data.get('workspace', {}).get('current_dir', '')
branch = get_git_branch(cwd) if cwd else ''
if branch:
    line2.append(f'{CYAN}\u2387 {branch}{R}')

if cwd:
    line2.append(f'{DIM}{shorten_path(cwd)}{R}')

five = data.get('rate_limits', {}).get('five_hour', {}).get('used_percentage')
if five is not None:
    line2.append(fmt('5h', five, width=6))

week = data.get('rate_limits', {}).get('seven_day', {}).get('used_percentage')
if week is not None:
    line2.append(fmt('7d', week, width=6))

cost = data.get('cost', {}).get('total_cost_usd')
if cost is not None and cost > 0:
    line2.append(f'{DIM}${cost:.2f}{R}')

# --- Line 3: Agent / Worktree (conditional) ---
line3 = []

agent_name = data.get('agent', {}).get('name') if isinstance(data.get('agent'), dict) else None
if agent_name:
    line3.append(f'{DIM}\u25b8 agent:{R} {agent_name}')

worktree = data.get('worktree', {})
if isinstance(worktree, dict) and worktree.get('name'):
    wt_info = f'{DIM}\u25b8 worktree:{R} {worktree["name"]}'
    wt_branch = worktree.get('branch')
    if wt_branch:
        wt_info += f' {DIM}({wt_branch}){R}'
    line3.append(wt_info)

session_name = data.get('session_name')
if session_name:
    line3.append(f'{DIM}\u25b8 session:{R} {session_name}')

# --- Output ---
print(SEP.join(line1))
if line2:
    print(SEP.join(line2))
if line3:
    print(SEP.join(line3))
