# What's for dinner

An rake task takes two input files(a csv file representing items and a json file representing recipes) to produce output what to cook for dinner tonight.

## Getting started

Two input files like below:
- csv file
  e.g.: item,quantity,unit_of_measure,use_by_date
        bread,3,slices,15/03/2021
        bread,1,slices,28/02/2021
        cheese,4,slices,22/08/2021
        vegemite,3,grams,30/05/2021
- json file
  [
    {
      "name": "Toasted Cheese",
      "ingredients": [
        { "item":"bread", "quantity":"2", "unit-of-measure":"slices"},
        { "item":"cheese", "quantity":"3", "unit-of-measure":"slices"}
      ]
    },
    {
      "name": "Vegemite Sandwich",
      "ingredients": [
        { "item":"bread", "quantity":"2", "unit-of-measure":"slices"},
        { "item":"vegemite", "quantity":"100", "unit-of-measure":"grams"}
      ]
    }
  ]

### Running the app
```
bundle exec rake "whats_for_dinner[my_fridge.csv, my_recipes.json]"
```

### Running the specs
```
bundle exec rspec spec/lib/tasks/whats_for_dinner_rake_spec.rb
```
