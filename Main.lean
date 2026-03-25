import SolfunmemeLean

def main : IO Unit := do
  federalModelMain
  IO.println ""
  governanceMain
  IO.println ""
  federalGovMain
  IO.println ""
  billsMain
