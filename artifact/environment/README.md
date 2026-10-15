# Environment

Two dependency records are intentionally retained:

- `system_source/fuzzer/requirements.txt` is the historical dependency specification shipped with the implementation.
- `windows-python39-lock.txt` is the transitive package closure observed in the Windows/Python 3.9.12 environment that passed import and CLI smoke checks for this artifact.

The two files differ for `web3`, `py-evm`, `py-solc-x`, and `z3-solver`. This is disclosed rather than hidden because a reviewer cannot infer which set produced every archived run from the current evidence. The compatibility import in `storage_emulation.py` supports the observed `py-evm` layout.

Create an isolated review environment with:

```powershell
py -3.9 -m venv .venv-seminv-artifact
.\.venv-seminv-artifact\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r artifact\environment\windows-python39-lock.txt
```

Do not store API keys in this repository. Copy `system_source/.env.example` to a local `.env` only when LLM-assisted stages are intentionally rerun.

