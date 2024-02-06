---
title: "Github 블로그 운영"
layout: archive
permalink: categories/blogs
author_profile: true
sidebar_main: true
---


{% assign posts = site.categories.blogs %}
{% for post in posts %} 
    {% include archive-single2.html type=page.entries_layout %} 
{% endfor %}
