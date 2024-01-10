## Speaker Notes

You can add speaker notes to a slide using a div with class `.notes`. For example:

```{.markdown example-link="/docs/presentations/revealjs/examples/speaker-notes.qmd"}
## Slide with speaker notes

Slide content

::: {.notes}
Speaker notes go here.
:::
```

This is a Revealjs feature from [built-in plugin](https://revealjs.com/plugins/#built-in-plugins) which brings limitation:  the content cannot rely on external dependencies. For instance, if you want to include a mermaid diagram that typically needs mermaid.js, it will need to be embed as an SVG or PNG image.
