---
title: "오라클 데이터베이스"
layout: archive
permalink: categories/Oracle
author_profile: true
sidebar_main: true
---

{% assign posts = site.categories.Oracle %}
{% for post in posts %} 
    {% include archive-single2.html type=page.entries_layout %} 
{% endfor %}
