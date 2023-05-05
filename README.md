# `LoadDependenciesOf` also loads module itself
Tests run with GHC 9.4.4. See [bin/Main.hs](bin/Main.hs).

# Expected
```
[]
Succeeded
[]
```

## Actual
```
[]
Succeeded
[ModSummary {
    ms_hs_hash = 154c8207fb74c60096bf34e3cbe34208
    ms_mod = Foo,
    unit = main
    ms_textual_imps = [(, Prelude)]
    ms_srcimps = []
 }]
```