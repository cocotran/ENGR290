--[[ 
Name: Quang Anh Tran
ID:   40075748
# Exercise: strings, concatenation, and formatting

Replace underscores (__) in the tests below with values to make tests correct.
Hint: change `is(__, 'a'..'b', '...')` to `is('ab', 'a'..'b', '...')` to pass the test.
After making the changes, run the tests to see the results.
]]
require "testwell"
is('', '', 'Strings can be empty')
is("Hello, World!", "Hello, World!", 'Strings in double quotes')
is("Hello, World!", "Hello, " .. 'World!', 'Strings concatenated using ..')
is("She said, 'I love to code'", "She said, 'I love to code'", 'Single quotes in double quotes')
is('abc', 'a' .. 'b' .. 'c', 'Expressions with multiple concatenations')
is('abc', 'a' .. ('b' .. 'c'), 'Parentheses used for grouping')
is("I'm 8 years old", "I'm ".. 8 .." years old", 'Numbers convert to strings')
is("I'm 8 years old", ("I'm %d years old"):format(8), 'Strings can be formatted')
is("5 is more than 2", ("%d is more than %d"):format(5, 2), 'Strings with placeholders')
report()