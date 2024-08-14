---
title: "논문 및 기술 문서 요약"
layout: archive
permalink: categories/thesis
author_profile: true
sidebar_main: true
---


{% assign posts = site.categories.thesis %}
{% for post in posts %} 
    {% include archive-single2.html type=page.entries_layout %} 
{% endfor %}
