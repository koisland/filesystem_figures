import json
import hashlib
from os.path import join, dirname


def create_find_ignore_patterns(patterns: list[str]) -> str:
    return " ".join([
        f'-not -wholename "{pattern}"'
        for pattern in patterns
    ])
