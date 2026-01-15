require 'json'
require 'algolia'
require 'open-uri'

apiKey = ENV["ALGOLIA_API_KEY"]
appId = ENV["ALGOLIA_APP_ID"]
indexName = ENV["ALGOLIA_INDEX"]
indexFile = ENV["QUARTO_INDEX_PATH"]
indexUrl = ENV["QUARTO_INDEX_URL"]

# Download the index from deployed website
download = URI.open(indexUrl)
IO.copy_stream(download, indexFile)

client = Algolia::SearchClient.create(appId, apiKey)
file    = File.read(indexFile)
records = JSON.parse(file)

# The API client automatically batches your records
client.replace_all_objects(indexName, records)

# Apply settings from config file
configFile = File.read('.github/workflows/algolia-config.json')
config = JSON.parse(configFile)

client.set_settings(indexName, config['settings'])

# Apply synonyms if present
if config['synonyms'] && !config['synonyms'].empty?
  client.save_synonyms(indexName, config['synonyms'], nil, true)
end

# Apply rules if present
if config['rules'] && !config['rules'].empty?
  client.save_rules(indexName, config['rules'], nil, true)
end
