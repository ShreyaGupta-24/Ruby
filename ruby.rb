def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_raw
    .map { |br| br.strip }
    .reject { |br| br.empty? }
    .map { |br| br.split(", ") }
    .filter do |dt|
    dt[0] == "CNAME" || dt[0] == "A"
  end
    .each_with_object({}) do |dt, dts|
    dts[dt[1]] = { type: dt[0], target: dt[2] }
  end
end

def resolve(dns_records, lookup_chain, domain)
  dt = dns_records[domain]
  if (!dt)
    lookup_chain << "Record not found: " + domain
    return lookup_chain
  elsif dt[:type] == "CNAME"
    lookup_chain << dt[:target]
    resolve(dns_records, lookup_chain, dt[:target])
  else dt[:type] == "A"
    lookup_chain << dt[:target]
    return lookup_chain   end
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
