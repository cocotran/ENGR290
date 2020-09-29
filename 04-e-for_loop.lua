--[[ 
Name: Quang Anh Tran
ID:   40075748
# Exercise: For loop

Fill in each for_loop#() function to create the desired array using a for loop
]] 

require "testwell"

function for_loop1(len)
  local out = {}
  -- Put your code between here **************** 

  for i=1, len do
    table.insert(out, i)
  end

  -- and here **********************************
  return out
end

is(for_loop1(4), {1,2,3,4}, 'For loop array creation len = 4')
is(for_loop1(9), {1,2,3,4,5,6,7,8,9}, 'For loop array creation  len = 9')

function for_loop2(a,b)
  local out = {}
  -- a is the starting number in the array
  -- b is the length of the array
  -- Put your code between here **************** 
  local count = a
  for i=a, (a+b - 1) do
    table.insert(out, a)
    a = a - 1
  end
  -- and here **********************************
  return out
end
is( for_loop2(4,4), {4,3,2,1}, 'For loop adaptable reversed array creation')
is( for_loop2(9,9), {9,8,7,6,5,4,3,2,1}, 'For loop adaptable reversed array creation')
is( for_loop2(4,9), {4,3,2,1,0,-1,-2,-3,-4}, 'For loop adaptable reversed array creation')
report()
