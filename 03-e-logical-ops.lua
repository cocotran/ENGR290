--[[
Name: Quang Anh Tran
ID:   40075748
# Exercise: logical operators

Replace underscores (__) in the tests below with values to make tests correct.
Hint: change `is(__, false, '...')` to `is(false, false, '...')`  to pass the test.
After making the changes, run the tests to see the results.
]]
require "testwell"
is(true, not false, 'not operator')
is(false, true and false, 'and operator')
is(true, true or false,  'or operator')
is(false, not(true or false) and true,  'not and or operators')
is(false, true and false or not false and not true,  'operator precedence')
is(false, (true and false) or ((not false) and (not true)),  ' explicit (equivalent to previous example) operator precedence')
report()