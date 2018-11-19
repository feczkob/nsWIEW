function all_words = wordsc(input_string)
remainder = input_string;
all_words = {};
while (any(remainder))
  [chopped,remainder] = strtok(remainder);
  all_words {end+1} = chopped;
end