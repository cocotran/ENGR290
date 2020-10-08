--[[ 
Name: Quang Anh Tran
ID:   40075748
# Exercise: If then elseif then else  & for loop

Fill in the if_then_elseif() function to create the desired array using a for loop and an if then else statement.
The goal is to create an output table equivalent to the input table as per the following correspondence
{"1", "2", "3", "4", "5", "6", "7", "8", "9"} =>> {"a", "b", "c", "d", "e", "f", "n", "n", "n"} 
]] 

require "testwell"

function foo(arg)
  --arg is the table of numbers
  local out = {}
  local n = #arg
  -- Put your code between here **************** 
  for i=1, #arg do
    if arg[i] == 1 then
      table.insert( out, "a" )
    elseif arg[i] == 2 then
      table.insert( out, "b" )
    elseif arg[i] == 3 then
      table.insert( out, "c" )
    elseif arg[i] == 4 then
      table.insert( out, "d" )
    elseif arg[i] == 5 then
      table.insert( out, "e" )
    elseif arg[i] == 6 then
      table.insert( out, "f" )
    elseif arg[i] == 7 then
      table.insert( out, "n" )
    elseif arg[i] == 8 then
      table.insert( out, "n" )
    elseif arg[i] == 9 then
      table.insert( out, "n" )
    end
  end

  -- and here **********************************
  return out
end

is(foo({1,2}), {"a", "b"}, 'numbers to letters 1')
is(foo({1,2,3}), {"a", "b", "c"}, 'numbers to letters 2')
is(foo({1,2,3,4}), {"a", "b", "c", "d"}, 'numbers to letters 3')
is(foo({1,2,3,4,5}), {"a", "b", "c", "d", "e"}, 'numbers to letters 4')
is(foo({1,2,3,4,5,6}), {"a", "b", "c", "d", "e", "f"}, 'numbers to letters 5')
is(foo({1,2,3,4,5,6,7}), {"a", "b", "c", "d", "e", "f", "n"}, 'numbers to letters 6')
is(foo({1,2,3,4,5,6,7,8}), {"a", "b", "c", "d", "e", "f", "n", "n"}, 'numbers to letters 7')
is(foo({1,2,3,4,5,6,7,8,9}), {"a", "b", "c", "d", "e", "f", "n", "n", "n"}, 'numbers to letters 8')
is(foo({9,8,7,6,5,4,3,2,1}), {"n", "n", "n", "f", "e", "d", "c", "b", "a"}, 'numbers to letters reversed')
report()
