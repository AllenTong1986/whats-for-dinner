require 'csv'

task :whats_for_dinner, [:my_fridge, :my_recipes] => :environment do |_task, args|
  begin
    puts args[:my_recipes]
    fridge = Fridge.new(args[:my_fridge])

    puts "Dinner tonight: "
  rescue ArgumentError
    puts "Invalid input files."
  end
end

class Fridge
  attr_reader :fridge_csv, :ingredients

  def initialize(fridge_csv)
    @fridge_csv = Rails.root.join("lib/tasks/#{fridge_csv}")
    @ingredients = fill_fridge
  end

  private

  # Return a hash. Example: {"bread_2021-03-05" => {quantity: 2, um: "slices"}}  
  def fill_fridge
    {}.tap do |fridge|
      ::CSV.foreach(fridge_csv, headers: true) do |row|
        if fridge["#{row[0]}_#{row[3]}"]
          fridge["#{row[0]}_#{row[3]}"][:quantity] += Integer(row[1])
        else
          fridge["#{row[0]}_#{row[3]}"] = {quantity: Integer(row[1]), um: row[2]}
        end
      end
    end
  end
end
