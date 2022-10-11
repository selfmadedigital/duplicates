# frozen_string_literal: true

require 'find'
require 'set'
require 'digest'
require 'fileutils'

checksums = {}
duplicates = Set[]
error = false

if ARGV.length < 2
  puts 'Missing parameter'
  error = true
elsif ARGV.length > 2
  puts 'Too much parameters'
  error = true
else
  unless File.directory?(ARGV[0])
    puts 'Parameter 1 must  be directory'
    error = true
  end
end

exit if error

def group_duplicates(file, checksums)
  md5 = Digest::MD5.file(file).hexdigest
  if checksums.key? md5
    files = Array checksums[md5]
    files.push(file)
  else
    files = [file]
  end
  checksums[md5] = files
  checksums
end

def compare_duplicates(files, duplicates)
  files.each_with_index do |fileForCompare, file_index|
    first_file = File.open(fileForCompare)
    (file_index + 1..files.length - 1).each do |fileIndex2|
      file_for_compare_2 = files[fileIndex2]
      secondFile = File.open(file_for_compare_2)
      index = 0

      File.read(first_file).each_byte do |b|
        break if File.read(secondFile).getbyte(index) != b
      end
      index += 1

      if File.read(first_file).length == index
        duplicates.add?(checksum)
      else
        break
      end
    end
  end
end

Dir.glob("#{ARGV[0]}/**/#{ARGV[1]}").each do |file|
  next unless File.file?(file)

  group_duplicates(file, checksums)
end

checksums.each do |_checksum, files = []|
  next unless files.length > 1

  compare_duplicates(files, duplicates)
end

duplicates.each do |hash|
  puts "#{hash} - [#{(Array checksums[hash]).join(', ')}]"
end
