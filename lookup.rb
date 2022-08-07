def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end
domain = get_command_line_argument
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
    return lookup_chain
  end
end
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
