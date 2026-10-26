script "stack_SQLite_Tour_card_id_1206"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "Edit Databases" (id 1206)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
  put "" into fld "users"
  put "" into fld "apps"
  pass preOpenCard
end preOpenCard

