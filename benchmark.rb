require 'benchmark'

class Elem
  attr_accessor :id

  def initialize(id)
    @id = id
  end
end

# Taken from active record
unless Enumerable.method_defined? :each_with_object 
  Enumerable.module_eval do
    def each_with_object(memo)
      return to_enum :each_with_object, memo unless block_given?
      each do |element|
        yield element, memo
      end
      memo
    end
  end
end

SAMPLES = 2

[10,1000,5000].each do |size|

  ids = size.times.sort_by { rand }
  results = ids.size.times.map { |x| Elem.new(x) } 

  puts "\nArray size = #{size}"

  Benchmark.bm(20) do |x|

    x.report "each_with_object" do
      SAMPLES.times do
        result_hash = nil
        result_hash = results.each_with_object({}) {|result,result_hash| result_hash[result.id] = result } 
        ids.map {|id| result_hash[id]}
      end
    end

    x.report "sort" do
      SAMPLES.times do 
        results.sort {|a, b| ids.index(a.id) <=> ids.index(b.id)}
      end
    end

    x.report "sort_cached_indexes" do

      SAMPLES.times do

        ids_index = {}

        ids.each_with_index do |id,index|
          ids_index[id] = index
        end

        results.sort {|a, b| ids_index[a.id] <=> ids_index[b.id]}
      end

    end

    x.report "inject_detect" do
      SAMPLES.times do
        ids.inject([]){|res, val| res << results.detect {|u| u.id == val}}
      end
    end

    x.report "sort_by" do
      SAMPLES.times do
        results.sort_by{|obj| ids.index(obj.id)}
      end
    end

    x.report "sort_by_cached_index" do
      SAMPLES.times do

        ids_index = {}

        ids.each_with_index do |id,index|
          ids_index[id] = index
        end

        results.sort_by{|obj| ids_index[obj.id]}
      end
    end

    x.report "sort_by_cached_index2" do
      SAMPLES.times do

        ids_index = {}
        idx = 0
        ids.each do |id|
          ids_index[id] = idx
          ++idx
        end

        results.sort_by{|obj| ids_index[obj.id]}
      end
    end



end

end
