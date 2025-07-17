import os
import json
from algoliasearch.search.client import SearchClientSync

api_key = os.getenv("ALGOLIA_QUARTO_WRITE")
app_id = "ZPJB5I1QN7"
index_name = "prod_QUARTO" 

client = SearchClientSync(app_id, api_key)

response = client.get_settings(
    index_name = index_name,
)

current_settings = json.loads(response.to_json())
print(json.dumps(current_settings, indent=4))

# Keep a copy of old settings just in case
with open("tools/algolia-old-settings.json", "w") as f:
    json.dump(current_settings, f, indent=4)

# Read setting from repo
with open("tools/algolia-index-configuration.json", "r") as f:
    new_settings = json.load(f)

# Replace on Algolia settings with those in repo
response = client.set_settings(
    index_name = index_name,
    index_settings = new_settings
)