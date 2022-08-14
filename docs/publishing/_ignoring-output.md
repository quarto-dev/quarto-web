It's important to note that you don't need to check your `_site` or `_book` directory into version control (if you have done this in the past you know it makes for very messy diffs!). Before proceeding you should add the output directory of your project to `.gitignore`. For example:


```{.bash filename=".gitignore"}
/.quarto/
/_site/
```

If you've already checked these files into source control you may need to remove them explicitly:

```{.bash filename="Terminal"}
git rm -r _site
```
