---
title: "마이크로서비스 아키텍쳐(MSA)"
layout: archive
permalink: categories/msa
author_profile: true
sidebar_main: true
---

{% assign posts = site.categories.msa %}
{% for post in posts %} 
    {% include archive-single2.html type=page.entries_layout %} 
{% endfor %}
