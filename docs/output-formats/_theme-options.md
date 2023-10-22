## Theme Options

You can do extensive customization of themes using [Sass](https://sass-lang.com/). Bootstrap defines over 1,400 Sass variables that control fonts, colors, padding, borders, and much more. You can see all of the variables here:

<https://github.com/twbs/bootstrap/blob/main/scss/_variables.scss>

Sass theme files can define both *variables* that globally set things like colors and fonts, as well as *rules* that define more fine grained behavior. To customize an existing Bootstrap theme with your own set of variables and/or rules, just provide the base theme and then your custom theme file(s):

``` yaml
theme:
  - cosmo
  - custom.scss
```

Your `custom.scss` file might look something like this:

``` css
/*-- scss:defaults --*/
$h2-font-size:          1.6rem !default;
$headings-font-weight:  500 !default;
$body-color:            $gray-700 !default;

/*-- scss:rules --*/
h1, h2, h3, h4, h5, h6 {
  text-shadow: -1px -1px 0 rgba(0, 0, 0, .3);
}
```

Note that the variables section is denoted by the `/*-- scss:defaults --*/` comment and the rules section (where normal CSS rules go) is denoted by the `/*-- scss:rules --*/` comment.

