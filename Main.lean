import SolfunmemeLean

def main : IO Unit := do
  IO.println "solfunmeme-lean: Lean4 proof checker ready"
  -- Test ledger JSON parsing
  match get_ledger_from_json_string ledger_account_string with
  | .ok l => IO.println s!"  Ledger: {l.account_name} ({l.entries.size} entries)"
  | .error e => IO.println s!"  Parse error: {e}"
