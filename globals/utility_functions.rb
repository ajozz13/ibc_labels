##Global utility functions
require 'date'
require 'time'

IBC_DATE_FORMAT = "%Y%m%d"
IBC_TIME_FORMAT = "%H%M"

def numeric? input
	true if Float( input ) rescue false
end
=begin
	Examples of Expressions to test
	Numeric %r{^\d*$}
	Non Numeric %r{^\D*$}
	Decimal %r{^\d{0,#{dig}}(?:\.\d{0,#{dec}})?$}
=end
def test_expression expr, input_test
	(input_test =~ expr) == 0 ? true : false
end

#currency Convert a string or money to a monetary
def to_currency input
	"%.2f" % input
end

#remove non-numerics from a string
def numeric_only input
	input.scan(/[\d+.]/).join('')
end 

def error_msg msg, exception, exit_code
        STDERR.write "#{ msg } \n#{ exception }\n"
        puts "Backtrace:"
        puts exception.backtrace
        exit exit_code unless exit_code < 1
end

def print_table table
	table.each_key { | key | puts "#{ key } = #{ table[ key ] }" }
end

def date_change date_str, date_format, desired_format=IBC_DATE_FORMAT
	d = case 
	when date_str == "today"
		Date.today
	else
		Date.strptime(date_str, date_format)
	end
	d.strftime( desired_format )
end

def time_change time_str, time_format, desired_time_format=IBC_TIME_FORMAT
	#t = Time.parse( time_str )
	t = Time.strptime(time_str, time_format)
	t.strftime( desired_time_format )
end

