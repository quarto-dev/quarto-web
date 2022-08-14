For example, here is a shell script that publishes to Netlify based on the information in a `_publish.yml` file in the root of the project:

```{.bash filename="Terminal"}
# credentials from https://app.netlify.com/user/applications
export NETLIFY_AUTH_TOKEN="45fd6ae56c"

# publish to the netlify site id provided within _publish.yml
quarto publish netlify
```

Here are the contents of `_publish.yml`:

``` yaml
- source: project
  netlify:
    - id: "5f3abafe-68f9-4c1d-835b-9d668b892001"
      url: "https://tubular-unicorn-97bb3c.netlify.app"
```

Here is another variation that provides the publish target on the command line:

```{.bash filename="Terminal"}
quarto publish netlify --id 5f3abafe-68f9-4c1d-835b-9d668b892001
```
