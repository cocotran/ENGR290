--[[
Name: Quang Anh Tran
ID:   40075748
# Exercise: numbers, operations, and priority

Replace underscores (__) in the tests below with values to make tests correct.
Hint: change `is(__, 2+3, '...')` to `is(5, 2+3, '...')` to pass the test.
After making the changes, run the tests to see the results.
]] 
require "testwell"
is(6, 1 + 2 * 3 - 1, 'Multiplication done before addition and subtraction')
is(8, (1 + 2) * 3 - 1, 'Parentheses change priority of operations')
is(6, (1 + 2) * (3 - 1), 'Parentheses are calculated left-to-right')
is(1, 12 / 4 / 3, 'Same priority operations [division] done left-to-right')
is(9, 12 / 4 * 3, 'Same priority operations [mixed] done left-to-right')
is(1, 12 / (4 * 3), 'Same priority operations [mixed] with grouping')
is(5, 14 - 6 - 3, 'Same priority operations [subtraction] done left-to-right')
is(11, 14 - (6 - 3), 'Same priority operations [subtraction] with grouping')
is(3, 2 * 1.5, 'Numbers may include a decimal point')
report()