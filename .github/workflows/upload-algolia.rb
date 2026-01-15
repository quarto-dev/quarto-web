gem 'algolia', '=2.3.4'
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

client  = Algolia::Search::Client.create(appId, apiKey)
index   = client.init_index(indexName)
file    = File.read(indexFile)
records = JSON.parse(file)

# The API client automatically batches your records
index.replace_all_objects(records, {})

# Apply settings from config file
configFile = File.read('.github/workflows/algolia-config.json')
config = JSON.parse(configFile)

index.set_settings(config['settings'])

# Apply synonyms if present
if config['synonyms'] && !config['synonyms'].empty?
  index.save_synonyms(config['synonyms'], { replaceExistingSynonyms: true })
end

# Apply rules if present
if config['rules'] && !config['rules'].empty?
  index.save_rules(config['rules'], { clearExistingRules: true })
end
