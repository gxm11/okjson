load "../okjson.rb"
load "../patchxp.rb"

Dir.glob("../t/valid-*.json").each do |fn|
  json = File.read(fn)
  exp = File.read(fn + ".exp")

  data = OkJson.decode(json)
  p data
  print(exp)
end

exit
