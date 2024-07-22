---
layout: single
title: 당신도 AI를 잘사용할수 있어!(ft. Fabric)
date: 2024-07-21 21:00
categories: 
  - llm 
tags: 
   - fabric
   - LLM
excerpt : LLM을 사용하기 위해서 프롬프트를 잘 작성해야합니다. 프롬프트는 모르겠고, 그냥 AI를 잘사용하고 싶어요.
header : 
  teaser: /assets/images/blog/ai1.jpg
  overlay_image: /assets/images/blog/ai1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

LLM을 잘 사용하려면 프롬프트 기술이 필요합니다. 내가 원하는 답변을 요청하기 위하여 프롬프트을 잘 작성 해야하지만, 프롬프트를 잘 작성하면 한번에 원하는 답변을 받음으로써 비용도 줄일수 있습니다. 

저는 네이버와 구글에 키워드로 검색하고, 단답으로 질문했던 시대 사람으로 LLM에게 친절하게 요청사항을 설명하기란 여간 힘든일이 아니었습니다.

알아서 어린이를 대하듯 친절하게 자세하게, 명확하게 요청하는 프롬프트을 사용할수 있도록 도와주는 Fabric 오픈소스를 소개하려고 합니다. 

## Fabric 오픈소스 소개

Fabric는 2023년 생성형 AI의 시작이후 수많은 AI 애플리케이션이 개발되었지만, 일반 사람들이 사용하기에는 쉽지않다는 문제점에서 출발하였습니다. 사람이 AI를 쉽게 사용할수 있도록 프롬프트 영역을 Pattern으로 숨기고 사전 정의된 pattern를 이용하여 AI를 쉽게 사용하는 기능을 제공합니다. 

AI개발자인 Daniel Miessler가 2023년부터 AI관련 워크플로우를 개발하다가 2024년에 fabric이라는 프로젝트로 변경하여 오픈소스로 제공하게되었습니다. 

- Daniel Miessler 개발자 : <https://danielmiessler.com/authors>{:target="_blank"}
  - 보안을 중요시 하는 AI 개발자로 AI로 가득한 세상에서 성공적이고 의미있는 삶을 구축하는 방법에 대한 독창적인 아이디어, 도구 및 사고모델을 지속적으로 공유하고 있습니다.
  - 비지도 학습관련된 블로그 글을 게재하고 있습니다. 
- Fabric를 만든 이유 : <https://danielmiessler.com/p/fabric-origin-story>{:target="_blank"} 
  - AI사용하기 어려웠던점 -> 컴포넌트 개발 -> CLI로 AI 호출 -> 전체적인 워크프로우를 수행하기 위하여 명령어 연결(chain) 
- Fabric github 사이트 : <https://github.com/danielmiessler/fabric>{:target="_blank"}

> Fabric는 AI를 사용하여 Human을 증강시키기 위한 오픈소스 프레임워크입니다. 특정 문제를 해결하기 위해 어디서나 사용할수 있는 AI프롬프트 세트를 제공하는 모듈식 프레임워크를 제공합니다. 

Fabric는 많이 존재하는 프롬프트를 수집하고 통합하는 기능을 제공합니다. Fabric는 일상생활에서 사용하는 업무에서 사용할수 있는 프롬프트를 Pattern이라고 불리우며, 최대한 가독성과 편집 가능성을 제공하기 위하여 Markdown으로 작성되어 있습니다. 

**Pattern 목록들**

Fabric은 아래와 같은 패턴(Pattern)들을 제공합니다. 

- YouTube 비디오와 팟캐스트의 가장 흥미로운 부분을 추출하기
- 아이디어 입력만으로 자신의 목소리로 에세이 작성하기
- 이해하기 어려운 학술 논문 요약하기
- 글의 주제에 완벽하게 맞는 AI 아트 프롬프트 생성하기
- 콘텐츠의 품질을 평가하여 읽거나 볼 가치가 있는지 판단하기
- 긴 지루한 콘텐츠 요약하기
- 코드 설명하기
- 나쁜 문서를 사용 가능한 문서로 변환하기
- 어떤 콘텐츠 입력이든 소셜 미디어 게시물로 만들기
- 그리고 수많은 다른 활동들...

**Fabric에서 작성된 패턴 예시**

- Pattern 명 : extract_wisdom 
- 내용 : 주어진 텍스트에서 흥미로운 내용을 요약해주는 프롬프트임

```markdown
# IDENTITY and PURPOSE

You extract surprising, insightful, and interesting information from text content. You are interested in insights related to the purpose and meaning of life, human flourishing, the role of technology in the future of humanity, artificial intelligence and its affect on humans, memes, learning, reading, books, continuous improvement, and similar topics.

Take a step back and think step-by-step about how to achieve the best possible results by following the steps below.

# STEPS
- Extract a summary of the content in 25 words, including who is presenting and the content being discussed into a section called SUMMARY.
- Extract 20 to 50 of the most surprising, insightful, and/or interesting ideas from the input in a section called IDEAS:. If there are less than 50 then collect all of them. Make sure you extract at least 20.
- Extract 10 to 20 of the best insights from the input and from a combination of the raw input and the IDEAS above into a section called INSIGHTS. These INSIGHTS should be fewer, more refined, more insightful, and more abstracted versions of the best ideas in the content.
- Extract 15 to 30 of the most surprising, insightful, and/or interesting quotes from the input into a section called QUOTES:. Use the exact quote text from the input.
- Extract 15 to 30 of the most practical and useful personal habits of the speakers, or mentioned by the speakers, in the content into a section called HABITS. Examples include but aren't limited to: sleep schedule, reading habits, things they always do, things they always avoid, productivity tips, diet, exercise, etc.
- Extract 15 to 30 of the most surprising, insightful, and/or interesting valid facts about the greater world that were mentioned in the content into a section called FACTS:.
- Extract all mentions of writing, art, tools, projects and other sources of inspiration mentioned by the speakers into a section called REFERENCES. This should include any and all references to something that the speaker mentioned.
- Extract the most potent takeaway and recommendation into a section called ONE-SENTENCE TAKEAWAY. This should be a 15-word sentence that captures the most important essence of the content.
- Extract the 15 to 30 of the most surprising, insightful, and/or interesting recommendations that can be collected from the content into a section called RECOMMENDATIONS.

# OUTPUT INSTRUCTIONS
- Only output Markdown.
- Write the IDEAS bullets as exactly 15 words.
- Write the RECOMMENDATIONS bullets as exactly 15 words.
- Write the HABITS bullets as exactly 15 words.
- Write the FACTS bullets as exactly 15 words.
- Write the INSIGHTS bullets as exactly 15 words.
- Extract at least 25 IDEAS from the content.
- Extract at least 10 INSIGHTS from the content.
- Extract at least 20 items for the other output sections.
- Do not give warnings or notes; only output the requested sections.
- You use bulleted lists for output, not numbered lists.
- Do not repeat ideas, quotes, facts, or resources.
- Do not start items with the same opening words.
- Ensure you follow ALL these instructions when creating your output.
- Write in only Korean.

# INPUT
INPUT:
```

Pattern내용을 보면 "목적 및 지침", 수행해야할 작업", "출력에 대한 제약"을 명확하게 표현한것을 알수 있습니다. 이 Pattern는 LLM에 답변을 요청할때 system 영역으로 할당되어 사용됩니다. 사용자 컨텐츠를 Pattern에 기반하여 답변하기 때문에 효과적으로 일관된 결과를 제공할수 있게 됩니다. 


> Pattern은 일생 업무에서 사용할수 있는 프롬프트의 모음입니다.

## Fabric 설치 및 사용법

Fabric를 설치해보고 사용하는 방법에 대해서 알아보겠습니다. 

먼저 fabric 소스를 다운로드 받습니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
mkdir fabric
cd fabric
git clone https://github.com/danielmiessler/fabric.git
```

실행 로그입니다. 약 151M의 크기를 받습니다. 

```shell
$> git clone https://github.com/danielmiessler/fabric.git
Cloning into 'fabric'...
remote: Enumerating objects: 8135, done.
remote: Counting objects: 100% (2250/2250), done.
remote: Compressing objects: 100% (555/555), done.
remote: Total 8135 (delta 1783), reused 1739 (delta 1680), pack-reused 5885
Receiving objects: 100% (8135/8135), 151.01 MiB | 20.04 MiB/s, done.
Resolving deltas: 100% (3836/3836), done.
```

pipx도구를 설치합니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
python3 -m pip install --user pipx
python3 -m pipx ensurepath
```

pipx도구를 이용하여 fabric를 설치합니다.

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
cd fabric
pipx install .
```

설치 화면입니다. fabric를 설치하면 여러 도구가 설치됩니다. 

- fabric : CLI기반 명령어 도구
- fabric-api : API서비스서버(Flask기반)
- fabric-webui : UI웹페이지에서 API 테스트(Flask기반)
- 기타 도구
  - yt : youtube API를 통해 script추출하는 도구
  - ts : OpenAI Whisper API를 사용하여 audio파일로부터 script추출하는 도구
  - save : 콘텐츠를 저장하는 파이프라인(tee-like) 유틸리티(fabric의 결과를 곧바로 파일로 저장할수 있음)

```shell
$> pipx install .
  installed package fabric 1.2.0, installed using Python 3.12.3
  These apps are now globally available
    - fabric
    - fabric-api
    - fabric-webui
    - save
    - ts
    - yt
done! ✨ 🌟 ✨
```

fabric을 설정합니다. 각종 API연동 키를 설정합니다. 
fabric는 OpenAI, Claude, Google, Youtube을 지원합니다.
Youtube API Key는 yt명령어에서 사용됩니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
fabric --setup
```

설정 화면입니다. 저는 OpenAI Key와 Youtube Key를 입력하였습니다. 

```shell
$> fabric --setup
Welcome to Fabric. Let's get started.
Please enter your OpenAI API key. If you do not have one or if you have already entered it, press enter.
<OPEN_AI_KEY>
Please enter your claude API key. If you do not have one, or if you have already entered it, press enter.

Please enter your Google API key. If you do not have one, or if you have already entered it, press enter.

Please enter your YouTube API key. If you do not have one, or if you have already entered it, press enter.
<YOUTUBE API KEY>
Updating patterns...
Downloaded zip file successfully.
Extracted zip file successfully.
Patterns updated successfully.
Creating empty environment file...
Environment file created.
```

> API Key목록은 ~/.config/fabric/env 파일에 저장됩니다.

fabric 명령어에 대한 설정옵션을 확인합니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
fabric -h 
```

fabric는 입력한 텍스트에서 사전 정의된 pattern에 맞게 출력을 하게 됩니다. 
사용할 LLM모델을 지정할수 있습니다. 

```shell
usage: fabric [-h] [--text TEXT] [--copy] [--agents] [--output [OUTPUT]] [--session [SESSION]] [--clearsession CLEARSESSION] [--sessionlog SESSIONLOG] [--listsessions] [--gui] [--stream]
              [--list] [--temp TEMP] [--top_p TOP_P] [--frequency_penalty FREQUENCY_PENALTY] [--presence_penalty PRESENCE_PENALTY] [--update] [--pattern PATTERN] [--setup]
              [--changeDefaultModel CHANGEDEFAULTMODEL] [--model MODEL] [--listmodels] [--remoteOllamaServer REMOTEOLLAMASERVER] [--context]

An open source framework for augmenting humans using AI.

options:
  -h, --help            show this help message and exit
  --text TEXT, -t TEXT  Text to extract summary from
  --copy, -C            Copy the response to the clipboard
  --agents, -a          Use praisonAI to create an AI agent and then use it. ex: 'write me a movie script'
  --output [OUTPUT], -o [OUTPUT]
                        Save the response to a file
  --session [SESSION], -S [SESSION]
                        Continue your previous conversation. Default is your previous conversation
  --clearsession CLEARSESSION
                        deletes indicated session. Use 'all' to delete all sessions
  --sessionlog SESSIONLOG
                        View the log of a session
  --listsessions        List all sessions
  --gui                 Use the GUI (Node and npm need to be installed)
  --stream, -s          Use this option if you want to see the results in realtime. NOTE: You will not be able to pipe the output into another command.
  --list, -l            List available patterns
  --temp TEMP           set the temperature for the model. Default is 0
  --top_p TOP_P         set the top_p for the model. Default is 1
  --frequency_penalty FREQUENCY_PENALTY
                        set the frequency penalty for the model. Default is 0.1
  --presence_penalty PRESENCE_PENALTY
                        set the presence penalty for the model. Default is 0.1
  --update, -u          Update patterns
  --pattern PATTERN, -p PATTERN
                        The pattern (prompt) to use
  --setup               Set up your fabric instance
  --changeDefaultModel CHANGEDEFAULTMODEL
                        Change the default model. For a list of available models, use the --listmodels flag.
  --model MODEL, -m MODEL
                        Select the model to use
  --listmodels          List all available models
  --remoteOllamaServer REMOTEOLLAMASERVER
                        The URL of the remote ollamaserver to use. ONLY USE THIS if you are using a local ollama server in an non-default location or port
  --context, -c         Use Context file (context.md) to add context to your pattern
```

**사용가능한 모델 목록 확인**

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
fabric --listmodels
```

저는 OpenAI Key만 입력되어 있어서, OpenAI의 GPT모델이 확인됩니다. 
Local Models는 Ollama로 설정된 모델입니다. 
Local LLM관리를 위한 Ollama설치방법과 사용법은 아래 블로그를 참조하세요.
 - [Ollama로 Local LLM구축하기](/blog/llm/how-to-install-local-llms-using-ollama){: target="_blank"}

```shell
GPT Models:
gpt-3.5-turbo
gpt-3.5-turbo-0125
gpt-3.5-turbo-1106
gpt-3.5-turbo-16k
gpt-3.5-turbo-instruct
gpt-3.5-turbo-instruct-0914
gpt-4
gpt-4-0125-preview
gpt-4-0613
gpt-4-1106-preview
gpt-4-turbo
gpt-4-turbo-2024-04-09
gpt-4-turbo-preview
gpt-4o
gpt-4o-2024-05-13
gpt-4o-mini
gpt-4o-mini-2024-07-18

Local Models:
mistral:latest

Claude Models:

Google Models:

```


**사용가능한 Pattern 목록 확인**

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
fabric --list
```

실행화면입니다. 약 130개정도의 Pattern를 제공합니다.
내가 필요로 하는 프롬프트가 무엇인지 파악하기 힘든 부분은 있으나, 자주사용하는 패턴들만 남겨놓을수 있고, 사용자가 직접 Pattern를 만들어 놓고 재 사용할수 있습니다.

```shell
agility_story
ai
analyze_answers
analyze_claims
analyze_debate
analyze_incident
analyze_logs
analyze_malware
analyze_paper
analyze_patent
analyze_personality
analyze_presentation
analyze_prose
analyze_prose_json
analyze_prose_pinker
analyze_spiritual_text
analyze_tech_impact
analyze_threat_report
analyze_threat_report_trends
answer_interview_question
ask_secure_by_design_questions
capture_thinkers_work
check_agreement
clean_text
coding_master
compare_and_contrast
create_5_sentence_summary
create_academic_paper
create_ai_jobs_analysis
create_aphorisms
create_art_prompt
create_better_frame
create_coding_project
create_command
create_cyber_summary
create_git_diff_commit
create_graph_from_input
create_hormozi_offer
create_idea_compass
create_investigation_visualization
create_keynote
create_logo
create_markmap_visualization
create_mermaid_visualization
create_micro_summary
create_network_threat_landscape
create_npc
create_pattern
create_quiz
create_reading_plan
create_report_finding
create_security_update
create_show_intro
create_sigma_rules
create_stride_threat_model
create_summary
create_tags
create_threat_scenarios
create_upgrade_pack
create_video_chapters
create_visualization
explain_code
explain_docs
explain_project
explain_terms
export_data_as_csv
extract_algorithm_update_recommendations
extract_article_wisdom
extract_book_ideas
extract_book_recommendations
extract_business_ideas
extract_controversial_ideas
extract_extraordinary_claims
extract_ideas
extract_insights
extract_main_idea
extract_patterns
extract_poc
extract_predictions
extract_questions
extract_recommendations
extract_references
extract_song_meaning
extract_sponsors
extract_videoid
extract_wisdom
extract_wisdom_agents
extract_wisdom_dm
extract_wisdom_nometa
find_hidden_message
find_logical_fallacies
get_wow_per_minute
get_youtube_rss
improve_academic_writing
improve_prompt
improve_report_finding
improve_writing
label_and_rate
official_pattern_template
provide_guidance
rate_ai_response
rate_ai_result
rate_content
rate_value
raw_query
recommend_artists
show_fabric_options_markmap
suggest_pattern
summarize
summarize_debate
summarize_git_changes
summarize_git_diff
summarize_lecture
summarize_legislation
summarize_micro
summarize_newsletter
summarize_paper
summarize_prompt
summarize_pull-requests
summarize_rpg_session
to_flashcards
tweet
write_essay
write_hackerone_report
write_micro_essay
write_nuclei_template_rule
write_pull-request
write_semgrep_rule
```

Pattern 수정은 Pattern폴더(~/.config/fabric/patterns)에 있는 system.md파일을 수정하면 됩니다.
폴더 자체를 옮겨서 새로운 Patterns을 만들어도 되고, 기존 Pattern에 있는 system.md파일을 직접 수정해서 사용할수 있습니다. 

## Fabric 활용 방법

Fabric은 파이프라인을 사용하여 입력받은 텍스트를 지정된 Pattern으로 프롬프트 작성해서 LLM에 답변을 요청합니다. 

**사용방법**

```shell
echo '입력텍스트' | fabric --pattern {패턴명}
```

### 1. Youtube 요약 하기

아래 영상은 [Network Chunk](https://www.youtube.com/@NetworkChuck){:target="blank"}라는 인플루언스가 Fabric에 대해서 설명한 영상입니다. 
{% include video id="UbDyjIIGaxQ" provider="youtube" %}

영상을 요약해보고 어떤 내용인지 확인해보겠습니다. 
사용할 Pattern은 extract_wisdom(지혜를 추출해라) 입니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```python
yt --transcript https://youtube.com/watch?v=UbDyjIIGaxQ | fabric --stream --pattern extract_wisdom
```

실행 결과은 아래와 같습니다. 

```markdown
# SUMMARY

Daniel Meer introduces Fabric, an open-source AI tool designed to augment human capabilities by reducing friction in using AI to solve problems, enhancing productivity and understanding.

# IDEAS:

- Fabric is an open-source AI tool aimed at augmenting human capabilities.
- Daniel Meer created Fabric to reduce friction in using AI for problem-solving.
- Fabric's "Extract Wisdom" feature quickly summarizes extensive content.
- It uses crowdsourced and open-source prompts or "patterns" for AI interaction.
- Fabric allows users to interact with AI via command line, voice, or GUI.
- It supports integration with various AI models, including local servers.
- Fabric's CLI-native approach streamlines the use of AI for developers.
- Users can create custom patterns to solve specific problems with AI.
- Fabric encourages a "World of Text" philosophy for efficient information management.
- It enables quick transcription and analysis of spoken content into text.
- Fabric's patterns are designed to mimic human note-taking and summarization.
- The tool helps filter content, highlighting what deserves in-depth attention.
- Fabric's patterns are constantly improved through community contributions.
- It facilitates the creation of a personalized AI assistant tailored to individual needs.
- Daniel Meer's vision for Fabric is to increase human flourishing through AI.
- Fabric can be used to analyze personal habits and suggest improvements.
- The tool integrates with note-taking applications like Obsidian for seamless information capture.
- Fabric's philosophy aligns with augmenting, not replacing, human intelligence.
- It offers a framework for users to engage deeply with content selectively.
- Meer's background in cybersecurity and AI shapes Fabric's development focus.
- Fabric aims to help users navigate the overwhelming amount of digital content.
- The project represents a practical application of AI for personal development.
- Users can record and transcribe conversations for analysis and reflection.
- Fabric supports local and remote AI model usage for flexibility.
- The tool exemplifies the potential of AI in enhancing personal productivity and learning.

# INSIGHTS:

- Open-source AI tools like Fabric democratize access to advanced problem-solving capabilities.
- Crowdsourcing AI prompts accelerates the development of highly effective interaction patterns.
- A CLI-native approach to AI integration appeals to developers seeking efficiency.
- Customizable AI patterns empower users to tailor solutions to their unique challenges.
- Embracing a "World of Text" philosophy maximizes the utility of digital information.
- Augmenting human intelligence with AI can enhance our ability to process and understand complex content.
- Community contributions are vital for refining and expanding the capabilities of AI tools.
- Personalized AI assistants can significantly improve productivity and decision-making processes.
- The philosophy behind Fabric underscores the potential of AI to support human flourishing.
- Engaging selectively with content through AI assistance can optimize learning and comprehension.

# QUOTES:

- "Fabric is all about reducing friction to have AI help you solve problems."
- "These prompts or patterns have been carefully curated to solve a very specific problem."
- "You're basically telling it to act like a human. We don't know why it works."
- "Fabric is CLI native. You do everything here in the CLI."
- "My whole world is text and the ability to manipulate text."
- "I capture it immediately in a note and now that it's text... I have this world of text."
- "It's about getting everything into a text format so it can be used anywhere by anything, especially AI."
- "What I've done is take any piece of AI from any platform... collecting all these prompts into this concept called patterns."
- "It's not about replacing humans, but about augmenting humans to help us become better."
- "There's so much content being produced all the time... staying relevant in your space takes a tremendous amount of time."
- "I am using it to determine what I should go watch regularly."
- "Everything shouldn't be a summary. Sometimes you have to put the hard work in."
- "Don't take the weights out of the gym."
- "My context file is about increasing human flourishing by helping people identify, articulate, and pursue their purpose in life."
- "This is literally my soul that I'm translating it to text."
- "I've got this problem. Here's a pattern that can fix it."
- "I rarely have time to go back and watch the sermon throughout the week. So if I could just somehow digest it like this, that'd be amazing."
- "The past six months, I've been on a journey of being very particular, very intentional with what I consume."
- "This whole fabric project is making me rethink about the role of AI in my life."

# HABITS:

- Daniel Meer uses Fabric daily for personal productivity and problem-solving.
- Meer captures ideas immediately into notes to avoid storing them in his brain.
- Transcribes spoken content immediately to integrate into his digital note system.
- Uses Vim and the Terminal for efficient manipulation of text-based information.
- Regularly updates and refines custom AI patterns based on personal use cases.
- Engages deeply with selected content based on AI-recommended prioritization.
- Records conversations for transcription and analysis to enhance personal reflection.
- Integrates Fabric with Obsidian for seamless capture of insights into a digital second brain.
- Employs local and remote AI models depending on the task at hand.
- Utilizes Fabric's CLI interface for quick access to AI capabilities without GUI distractions.
- Prioritizes the development of new patterns to solve emerging personal challenges.
- Actively contributes to the open-source community by sharing improvements to patterns.
- Adopts a selective engagement approach to content consumption based on AI analysis.
- Practices immediate transcription of audio recordings into text for comprehensive review.
- Embraces a text-centric workflow for efficient information management and retrieval.

# FACTS:

- Fabric is an open-source project aimed at augmenting human capabilities with AI.
- Daniel Meer, a cybersecurity expert, created Fabric after leaving Robinhood in 2022.
- Fabric utilizes crowdsourced prompts or "patterns" for interacting with various AIs.
- It supports integration with major AI models from OpenAI, Anthropic, and local servers.
- Fabric is designed for use via command line, voice commands, or graphical interfaces.
- The project encourages users to create custom patterns for specific problem-solving needs.
- Fabric promotes a "World of Text" philosophy for efficient information management.
- Daniel Meer's vision for Fabric includes increasing human flourishing through technology.
- The tool allows users to filter digital content effectively, focusing on high-value materials.
- Community contributions play a crucial role in refining and expanding Fabric's capabilities.
- Fabric integrates with note-taking applications like Obsidian for seamless information capture.
- The project reflects a broader trend towards leveraging AI for personal development and productivity.
- Meer has a background in hacking and cybersecurity, influencing his approach to developing Fabric.

# REFERENCES:

- Daniel Meer introduces Fabric, an open-source tool designed to augment human capabilities with AI.
- The concept of "Extract Wisdom" as a feature within Fabric for summarizing content efficiently.
- Open source and crowdsourced prompts or "patterns" used in interacting with AIs through Fabric.
- Integration of Fabric with major AI models from OpenAI, Anthropic, and local servers like Alama.
- Use of command line interface (CLI) as a primary method for interacting with Fabric.
- The philosophy of creating a "World of Text" for efficient information management mentioned by Daniel Mesler.
- The practice of transcribing spoken content immediately into text format for integration into digital note systems.

# ONE-SENTENCE TAKEAWAY:

Fabric revolutionizes productivity by seamlessly integrating open-source AI into daily workflows, enhancing human capabilities.

# RECOMMENDATIONS:

- Explore using Fabric daily for enhanced productivity and problem-solving capabilities.
- Integrate spoken content into digital workflows through immediate transcription practices.
- Utilize Vim and Terminal for efficient manipulation of text-based information systems.
- Regularly update and refine custom AI patterns based on evolving personal needs.
- Prioritize deep engagement with content selectively recommended by AI analysis.
```

### 2. 한글로 출력하기

Pattern를 사용하면 기본 영어로 작성됩니다. 한국어로 작성이 필요할 경우 Pattern의 **OUTPUT INSTRUCTIONS** 영역에 **Write in korean**를 넣으면 됩니다. 

Pattern파일을 오픈합니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```
vi ~/.config/fabric/patterns/extract_wisdom/system.md
```

파일수정 내용입니다. 

```markdown
 53 - Do not start items with the same opening words.
 54
 55 - Ensure you follow ALL these instructions when creating your output.
 56
 57 - Write in Korean.   <-- 추가
 58
 59 # INPUT
 60
 61 INPUT:
```

다시 실행합니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```python
yt --transcript https://youtube.com/watch?v=UbDyjIIGaxQ | fabric --stream --pattern extract_wisdom
```

한국어로 출력하면 아래와 같습니다. 

```markdown
## SUMMARY

이 비디오에서는 Daniel Meer가 만든 오픈 소스 AI 도구인 Fabric에 대해 소개하고, 이를 사용하여 AI를 활용해 문제를 해결하는 방법을 설명합니다.

## IDEAS:

- Fabric은 인간과 AI 사이의 마찰을 줄여 문제 해결을 돕는다.
- 오픈 소스 및 크라우드소싱된 패턴을 사용하여 AI에게 명령한다.
- YouTube 동영상의 전사본을 추출하여 지혜와 통찰을 얻는다.
- CLI 기반으로 작동하여 AI와의 상호작용을 간소화한다.
- 다양한 AI 모델과 통합되어 유연한 사용이 가능하다.
- 사용자가 직접 패턴을 생성하여 문제 해결에 활용할 수 있다.
- 모든 정보를 텍스트 형식으로 변환하여 AI 처리에 용이하게 한다.
- Obsidian과 같은 노트 애플리케이션과 연동하여 지식 관리를 용이하게 한다.
- 인간의 플러리싱을 증진시키기 위해 개발되었다.
- AI를 인간의 능력을 확장하는 도구로 보고 활용한다.
- 패턴을 이용해 복잡한 데이터를 간단하게 요약하고 분석한다.
- 사용자 정의 패턴을 통해 개인화된 AI 경험을 제공한다.
- 텍스트 기반의 세계에서 AI를 활용하여 정보를 처리한다.
- AI와의 상호작용을 자연스러운 대화처럼 만들어 효율성을 높인다.
- 오픈 소스 커뮤니티를 통해 지속적으로 패턴을 개선한다.
- AI를 사용하여 인간의 삶의 질을 향상시키는 것을 목표로 한다.
- 인간과 AI의 협력을 통해 새로운 가능성을 탐색한다.
- AI를 활용하여 대량의 콘텐츠를 효율적으로 소비한다.
- 인간의 생각과 학습 과정을 AI로 확장하여 깊이 있는 분석을 가능하게 한다.
- AI를 이용해 개인의 목적과 플러리싱을 지원하는 컨텍스트를 생성한다.
- AI와의 상호작용을 통해 인간의 창의력과 생산성을 증진시킨다.

## INSIGHTS:

- Fabric은 AI와 인간 사이의 상호작용을 간소화하여 문제 해결력을 강화한다.
- 오픈 소스 패턴은 AI 사용자 경험을 개인화하고 최적화하는 데 중요하다.
- 텍스트 기반 정보 처리는 AI를 활용한 지식 관리의 핵심이다.
- 인간의 플러리싱은 AI 기술을 통해 새로운 차원으로 확장될 수 있다.
- 사용자 정의 패턴은 개인의 필요에 맞춘 AI 활용을 가능하게 한다.
- AI와 인간의 협력은 창의적 문제 해결과 혁신을 촉진한다.
- AI를 활용한 콘텐츠 소비 최적화는 지식 습득 과정을 가속화한다.
- 인간 중심의 AI 사용은 깊이 있는 학습과 분석을 촉진한다.
- 컨텍스트 기반 AI 활용은 개인의 목적 달성에 중요한 역할을 한다.
- AI 기술과 인간의 창의력 결합은 무한한 가능성을 열어준다.

## QUOTES:

- "Fabric은 인간과 AI 사이의 마찰을 줄여줍니다."
- "오픈 소스 및 크라우드소싱된 패턴으로 AI에게 명령합니다."
- "CLI 기반으로 작동하여 사용자 경험을 간소화합니다."
- "사용자가 직접 패턴을 생성할 수 있습니다."
- "모든 정보를 텍스트로 변환하여 처리합니다."
- "Obsidian과 연동하여 지식 관리를 용이하게 합니다."
- "인간의 플러리싱 증진이 목표입니다."
- "AI는 인간 능력의 확장 도구입니다."
- "패턴을 이용해 데이터를 간단하게 요약합니다."
- "AI와 자연스러운 대화를 통해 효율성을 높입니다."
- "오픈 소스 커뮤니티로 패턴을 지속적으로 개선합니다."
- "AI를 사용해 인간 삶의 질을 향상시킵니다."
- "인간과 AI 협력으로 새로운 가능성을 탐색합니다."
- "AI로 대량의 콘텐츠를 효율적으로 소비합니다."
- "AI로 깊이 있는 분석이 가능합니다."

## HABITS:

- 매일 Fabric 도구를 사용하여 문제 해결에 AI 활용한다.
- YouTube 동영상 전사본 추출로 시간 절약에 기여한다.
- CLI 환경에서 모든 작업 수행으로 생산성 향상시킨다.
- 오픈 소스 패턴 공유 및 개선에 적극 참여한다.
- Obsidian 노트 애플리케이션과 연동하여 지식 관리한다.
- 개인화된 패턴 생성으로 Fabric 사용 경험 최적화한다.
- 정보를 텍스트 형식으로 변환하여 AI 처리 용이하게 한다.
- 대량 콘텐츠 소비 최적화로 지식 습득 과정 가속화한다.
- 컨텍스트 기반 AI 활용으로 목적 달성에 집중한다.
- 인간 중심의 AI 사용으로 깊이 있는 학습 및 분석 촉진한다.

## FACTS:

- Fabric은 오픈 소스 AI 도구로, 인간과 AI 사이의 마찰을 줄인다.
- YouTube 동영상 전사본 추출 기능은 시간 절약에 크게 기여한다.
- CLI 기반 작동은 사용자 경험 간소화에 중요한 역할을 한다.
- 오픈 소스 및 크라우드소싱된 패턴은 사용자 경험 개인화에 기여한다.
- Obsidian과 연동 가능성은 지식 관리에 혁신적인 접근 방식을 제공한다.
- 사용자 정의 패턴 생성 기능은 Fabric의 유연성을 보여준다.
- 모든 정보를 텍스트 형식으로 변환하는 기능은 AI 처리에 핵심적이다.
- 대량 콘텐츠 소비 최적화는 정보 과부하 시대에 필수적이다.
- 컨텍스트 기반 AI 활용은 개인 목적 달성에 중요한 역할을 한다.
- 인간 중심의 AI 사용은 깊이 있는 학습 및 분석에 기여한다.

## REFERENCES:

- Fabric
- YouTube
- Obsidian
- CLI (Command Line Interface)
- Open Source Community
- Crowdsourced Patterns
- GPT Models from OpenAI and Anthropic
- Local Models with Alama
- Twin Gate
- Notion
- Vim and Terminal
- Whisper AI for Transcription

```

### 3. 문서 생성하기

fabric에 생성된 결과를 save명령어를 통해 문서로 저장할수 있습니다.
우선 환경 변수 설정이 필요합니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
mkdir -p /home/oracle/fabric/output
echo 'FABRIC_OUTPUT_PATH=/home/oracle/fabric/output' >> ~/.config/fabric/.env
```

콘텐츠를 생성합니다. FABRIC_OUTPUT_PATH환경 변수에 md파일로 생성됩니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
yt --transcript https://youtube.com/watch?v=UbDyjIIGaxQ | fabric --stream --pattern extract_wisdom | save --tag fabric  youve_been_using_ai_wrong
```

파일 생성을 확인합니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
ls -al /home/oracle/fabric/output
```

아래와 같은 파일이 생성된것을 확인할수 있습니다. 
- 2024-07-22-youve_been_using_ai_wrong.md

### 4. 요약 하기

파일을 읽어서 요약 작업을 할수 있습니다. 
(mac일경우는 copy한 텍스트를 곧바로 pbpaste명령어를 이용하여 fabric으로 연결할수 있습니다. )
summarize Pattern는 요약하는 프롬프트입니다. 영어로 출력되므로 한글로 작성하도록 설정하려면 2.한글로 출력하기를 참고하여 수정이 필요합니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
cat /home/oracle/fabric/output/2024-07-22-youve_been_using_ai_wrong.md | fabric --pattern summarize
```

요약한 내용입니다.

```markdown
ONE SENTENCE SUMMARY:
- Daniel Meer가 만든 오픈 소스 AI 도구 Fabric은 인간과 AI 사이의 마찰을 줄이고 문제 해결을 돕습니다.

MAIN POINTS:
1. Fabric은 인간과 AI의 상호작용을 간소화하여 문제 해결을 촉진한다.
2. 오픈 소스 및 크라우드소싱된 패턴으로 AI 명령을 최적화한다.
3. YouTube 동영상 전사본 추출 기능으로 시간 절약 및 통찰력 향상에 기여한다.
4. CLI 기반 작동으로 사용자 경험을 단순화하고 생산성을 높인다.
5. 다양한 AI 모델과의 통합으로 유연한 사용을 가능하게 한다.
6. 사용자 정의 패턴 생성으로 개인화된 AI 경험을 제공한다.
7. 텍스트 형식 변환 기능으로 AI 처리를 용이하게 한다.
8. Obsidian과 같은 노트 애플리케이션과의 연동으로 지식 관리를 강화한다.
9. 인간의 능력 확장 도구로서 AI의 활용을 강조한다.
10. 오픈 소스 커뮤니티를 통한 지속적인 패턴 개선을 추구한다.

TAKEAWAYS:
1. Fabric은 문제 해결에 있어 인간과 AI의 협력을 강화하는 중요한 도구다.
2. 오픈 소스 패턴은 AI 사용자 경험을 개인화하고 최적화하는 데 핵심적이다.
3. CLI 환경에서의 작업 수행은 생산성과 효율성을 높인다.
4. 정보를 텍스트 형식으로 변환하는 기능은 AI 처리에 있어 필수적이다.
5. 인간 중심의 AI 사용은 깊이 있는 학습 및 분석을 가능하게 한다.
```


### 5. 여러 작업 수행하기
 
fabric명령어간 파이프라인으로 연결되기 때문에 여러개의 작업을 Chain으로 연결이 가능합니다. 

AI의 미래라는 주제로 essay를 작성하고 파일(2024-07-22-essay.md)로 저장합니다. 그리고나서 요약작업을 하고 작업 결과를 파일(2024-07-22-essay_summary.md)로 저장합니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
echo "AI의 미래는 무엇일까?" |  fabric  --pattern write_essay | save essay | fabric --stream --pattern summarize  | save essay_summary
```


essay 내용입니다. 

```text
AI의 미래를 예측하는 것은 마치 미로 속에서 길을 찾으려는 것과 같다. 우리는 알고리즘의 복잡한 길목에서 다양한 가능성을 탐색하며, 
때로는 예상치 못한 결과에 직면하기도 한다. 그러나 이러한 불확실성 속에서도 AI의 발전이 가져올 변화에 대해 생각해보는 것은 매우 흥미로운 일이다.

첫째, AI는 우리의 일상생활을 더욱 편리하게 만들 것이다. 이미 우리는 스마트폰, 가정용 로봇, 자동화된 고객 서비스 등 다양한 분야에서 AI의 혜택을 받고 있다. 
앞으로 AI는 더욱 정교해지며, 우리의 취향과 선호도를 학습하여 개인화된 서비스를 제공할 것이다. 
예를 들어, AI가 우리의 건강 상태를 모니터링하고, 필요한 경우 의사와의 상담을 자동으로 예약해 주는 시대가 올 수 있다.

둘째, AI는 새로운 산업과 직업을 창출할 것이다. AI 기술의 발전은 기존의 일자리를 대체하는 것뿐만 아니라, 전혀 새로운 분야에서의 기회를 열어줄 것이다. 
예를 들어, AI 데이터 분석가, AI 윤리 전>문가, AI 시스템 트레이너와 같은 직업이 등장할 수 있다. 이러한 변화는 우리에게 새로운 기술을 배우고 적응하는 유연성을 요구할 것이다.

셋째, AI는 사회적 도전 과제를 해결하는 데 기여할 수 있다. 기후 변화, 질병의 진단 및 치료, 식량 안보 등 인류가 직면한 문제들에 대해 AI는 해결책을 제시할 수 있다. 
예를 들어, AI를 활용한 정밀 농업은 작물의 생산성을 높이고 자원을 효율적으로 사용하여 식량 문제를 완화할 수 있다. 또한, AI가 질병 패턴을 분석하여 새로운 치료법을 개발하는 데 기여할 수도 있다.

하지만 AI의 발전은 윤리적, 사회적 문제를 동반한다. 프라이버시 침해, 결정 과정의 투명성 부족, 편향된 알고리즘으로 인한 차별 등이 그 예이다. 
따라서 AI 기술의 발전과 함께 이러한 문제들을 해결>하기 위한 노력도 중요하다. AI 윤리 규정의 수립, 알고리즘의 투명성 확보, 다양성과 포용성을 고려한 기술 개발이 필요하다.

결론적으로, AI의 미래는 우리가 어떻게 준비하고 대응하느냐에 달려 있다. AI 기술의 긍정적인 측면을 극대화하고 부정적인 영향을 최소화하기 위한 지속적인 연구와 논의가 필요하다. 
AI가 인류에게 혜택을 가져다주는 동시에, 우리 사회의 가치와 원칙을 반영하는 방향으로 발전하기를 기대한다.
```

essay 의 요약 내용입니다. 

```markdown
ONE SENTENCE SUMMARY:
AI의 미래는 불확실성 속에서도 일상의 편리함, 새로운 직업 창출, 사회적 문제 해결에 기여하며 윤리적 고려가 필요하다.

MAIN POINTS:
1. AI의 미래 예측은 복잡한 알고리즘과 다양한 가능성 탐색을 포함한다.
2. AI는 일상생활을 편리하게 만들고 개인화된 서비스를 제공할 것이다.
3. 건강 모니터링과 자동 의사 상담 예약 같은 서비스가 가능해질 것이다.
4. 새로운 산업과 직업, 예를 들어 AI 데이터 분석가, 윤리 전문가가 생길 것이다.
5. AI는 기후 변화, 질병 진단, 식량 안보 등 사회적 도전을 해결할 수 있다.
6. 정밀 농업과 질병 패턴 분석을 통한 치료법 개발에 AI가 기여할 것이다.
7. AI 발전은 프라이버시 침해, 투명성 부족, 알고리즘 차별 등 문제를 동반한다.
8. AI 윤리 규정 수립, 알고리즘 투명성 확보, 다양성 고려가 중요하다.
9. AI 기술의 긍정적 측면 극대화와 부정적 영향 최소화를 위한 연구 필요.
10. 인류 혜택과 사회 가치 반영을 위한 AI 발전 방향에 대한 기대감.

TAKEAWAYS:
1. AI의 미래는 다양한 가능성과 함께 윤리적 고려가 필수적이다.
2. 일상생활의 편리함 증진과 개인화된 서비스 제공이 AI의 주요 기여 중 하나다.
3. 새로운 직업 창출을 통해 경제와 사회에 긍정적 변화를 가져올 것이다.
4. 사회적 도전 과제 해결에 AI가 중요한 역할을 할 수 있다.
5. AI 발전을 위해서는 지속적인 연구와 윤리적 기준 설정이 필요하다.
```


### 6. 프롬프트 강화하기 

내가 작성한 프롬프트를 강화하는데 사용할수도 있습니다. 
앞서 설명했듯이 저는 프롬프트 작성을 잘 못합니다. 자세히 설명을 해야하는데 너무 간단한 질문을 합니다. 그래서 프롬프트를 강화시켜는 패턴(improve_prompt)를 사용하여 프롬프트를 좀더 명확하게 작성하였습니다.

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
echo "최근 AI 기술 동향에 대해서 알려줘" |fabric --stream --pattern improve_prompt 
```

프롬프트 작성 결과입니다.

{% include codeHeader.html copyable="true" codetype="shell"%}
```markdown
최근 인공지능 기술의 발전과 동향에 대해 전문가 수준의 분석을 제공해주세요. 다음과 같은 세부 사항을 포함하여 답변해 주시기 바랍니다:

1. **기술 발전**: 최근 몇 년간 인공지능 분야에서 이루어진 주요 기술적 발전에 대해 설명해주세요.
2. **응용 분야**: 이러한 기술적 발전이 어떻게 다양한 산업이나 분야에 적용되고 있는지 구체적인 예시를 들어 설명해주세요.
3. **미래 전망**: 현재의 기술 동향을 바탕으로, 인공지능 기술이 향후 어떤 방향으로 발전할 것으로 예상되는지 전망해주세요.
4. **도전 과제와 한계점**: 현재 인공지능 기술 발전에 있어서 직면하고 있는 주요 도전 과제와 한계점에 대해 논의해주세요.

답변은 각 섹션별로 구분하여, 전문가 수준의 깊이와 세부 사항을 담아 4개의 단락으로 구성해주세요.
각 단락은 해당 주제에 대한 심도 있는 분석과 함께 최신 연구 결과나 사례를 인용하여 설명해주시기 바랍니다.
```


## 마무리 

지금까지 fabric 도구에 대한 사용방법에 대해 알아보았습니다.
많은 프롬프트들을 수집하고 이를 잘 사용할수 있도록 pattern이란 이름으로 제공합니다. 
프롬프트 자체를 스터디할때 도움이 될것같고, 내가 하는 업무에 사용하기 위해서는 약간의 수정은 필요할수 있으나 약 130개의 패턴중에 내가 원하는 프롬프트를 찾고 이를 변경하면 보다 빠르게 업무에 적용할수 있습니다. 

CLI기반으로 직관적으로 처리할수 있고, 필요하면 API화 시켜서 처리할수 있습니다. 
LLM을 사용하다보면 프롬프트 관리가 필요하게 됩니다. 프롬프트를 관리하는 방법에 대해 고민이 많았으면, 크게 유용하게 사용되는 도구가 될것 같습니다. 만들어진 프롬프트는 system 지시어로 사용되지만, 필요하면 컨텍스트 정보도 추가할수 있습니다. 

아래 내용은 위 활용방법에서 출력된 최종 결과입니다. 

**Fabric 요약 내용**

ONE SENTENCE SUMMARY:
- Daniel Meer가 만든 오픈 소스 AI 도구 Fabric은 인간과 AI 사이의 마찰을 줄이고 문제 해결을 돕습니다.

MAIN POINTS:
1. Fabric은 인간과 AI의 상호작용을 간소화하여 문제 해결을 촉진한다.
2. 오픈 소스 및 크라우드소싱된 패턴으로 AI 명령을 최적화한다.
3. YouTube 동영상 전사본 추출 기능으로 시간 절약 및 통찰력 향상에 기여한다.
4. CLI 기반 작동으로 사용자 경험을 단순화하고 생산성을 높인다.
5. 다양한 AI 모델과의 통합으로 유연한 사용을 가능하게 한다.
6. 사용자 정의 패턴 생성으로 개인화된 AI 경험을 제공한다.
7. 텍스트 형식 변환 기능으로 AI 처리를 용이하게 한다.
8. Obsidian과 같은 노트 애플리케이션과의 연동으로 지식 관리를 강화한다.
9. 인간의 능력 확장 도구로서 AI의 활용을 강조한다.
10. 오픈 소스 커뮤니티를 통한 지속적인 패턴 개선을 추구한다.

TAKEAWAYS:
1. Fabric은 문제 해결에 있어 인간과 AI의 협력을 강화하는 중요한 도구다.
2. 오픈 소스 패턴은 AI 사용자 경험을 개인화하고 최적화하는 데 핵심적이다.
3. CLI 환경에서의 작업 수행은 생산성과 효율성을 높인다.
4. 정보를 텍스트 형식으로 변환하는 기능은 AI 처리에 있어 필수적이다.
5. 인간 중심의 AI 사용은 깊이 있는 학습 및 분석을 가능하게 한다.

## 참고자료

- Fabric github 사이트 : <https://github.com/danielmiessler/fabric>{:target="_blank"}