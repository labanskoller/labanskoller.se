---
title: "New Static Blog Using Hugo"
author: Laban Sköllermark ([@LabanSkoller](https://twitter.com/LabanSkoller))
date: 2019-01-04T06:20:00+01:00
featured_image: blog/images/hugo-logo-wide.svg
images:
  - blog/images/hugo-logo-wide.svg
---
Inpired by [Hackeriet's blog](https://blog.hackeriet.no/) where Alexander Kjäll use to post CTF write-ups, I've decided to create a personal one for myself. Focus will be on IT security.

Hackeriet's blog is powered by [Jekyll](https://jekyllrb.com/) which is a static site generator written in Ruby. See their post _[Creating a fast blog](https://blog.hackeriet.no/creating-a-fast-blog/)_ for how they set up their blog. 


I have decided to try another static site generator called [Hugo](https://gohugo.io/), which is written in Go. By using a pre-built binary I don't need Ruby or Go installed. Hugo is just one file: `hugo`. After some initial configuration in the site's git I can add a new blog post using
```bash
$ hugo new blog/new-static-blog-using-hugo.md
```
and preview the post locally using
```bash
$ hugo server --buildDrafts
```
When I'm happy with the results I can remove the draft status, push a commit and render the whole site into the `public/` directory on the server by running just
```bash
$ hugo
```

UPDATED 2019-07-11: The source of this website is now available at GitHub: https://github.com/labanskoller/labanskoller.se
