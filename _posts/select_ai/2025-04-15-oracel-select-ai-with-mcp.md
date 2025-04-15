---
layout: single
title: "[오라클] MCP를 통해 SELECT AI기능 사용하기"
date: 2025-04-14 21:00
categories: 
  - Oracle 
tags: 
   - Oracle
   - SELECT AI
   - Model Context Protocol
excerpt : "생성형 AI에서 다양한 Tool을 요청할때 사용되는 MCP기능을 SELECT AI기능과 연동해보았습니다." 
toc : true  
toc_sticky: true
---
  
## 들어가며 

생성형 AI에서 다양한 Tools들을 쉽게 사용하기 위하여 앤트로픽에서 나온 MCP(Model Context Protocol) 프로토콜이 있습니다. 
다양한 업체에서 지원하면서 거의 표준화처럼 사용되다 보니 엄청 나게 많이 Tools들이 쏟아져 나오고 있습니다. 

Oracle Database의 Select AI기능을 MCP로 연결하는 작업을 알아보도록 하겠습니다.

## 실습 스크립트

### 1. Select AI 서비스 활성화

Select AI 는 NL2SQL를 제공하는 Oracle Database(23.7이상)의 기능으로 Oracle Database에서 직접 생성형 AI와 연동하여 SQL생성하고 실행시킵니다.
자연어로 데이터베이스내 데이터를 질의할수 있습니다. 

먼저 Oracle Database에서 Select AI 기능을 활성화 합니다. 
Select AI 기능을 사용하는 방법을 아래 블로그를 참고하시기 바랍니다.

- [SELECT AI기능 소개 ](/blog/oracle/introducing-select-ai/){:target="_blank"}

업무별로 두개의 Ai Profile을 생성했습니다. 
- ASK_HUMAN_RESOURCE: 인사 데이터 조회용 프로필
- ASK_SALES_HISTORY: 판매 내역 조회용 프로필

생셩형 AI가 사용자 질의에 적합한 프로필을 선택하수 있도록 프로필에 설명정보를 자세히 기재합니다.

**판매 내역 조회용 프로필**

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql 
BEGIN
  DBMS_CLOUD_AI.CREATE_PROFILE(
     profile_name => 'ask_sales_history',
     description=> 'AI profile that enables querying sales trends and performance using SH.SALES, PRODUCTS, COUNTRIES, COSTS, PROMOTIONS, CHANNELS, and TIMES tables',
     attributes =>
      '{"provider": "openai",
        "credential_name": "OPENAI_CRED",
        "object_list": [
            {"owner": "SH","name":"TIMES"},
            {"owner": "SH","name":"PRODUCTS"},
            {"owner": "SH","name":"COUNTRIES"},
            {"owner": "SH","name":"COSTS"},
            {"owner": "SH","name":"PROMOTIONS"},
            {"owner": "SH","name":"SALES"},
            {"owner": "SH","name":"CHANNELS"},
            {"owner": "SH","name":"CUSTOMERS"} ],
        "max_tokens":512, 
        "model": "gpt-4o",
        "temperature": 0.1,
        "comments": true
       }');
END;
/
```

**인사 데이터 조회용 프로필**

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
BEGIN
  DBMS_CLOUD_AI.CREATE_PROFILE(
     profile_name => 'ask_human_resource',
     description => 'AI profile that enables querying HR data using HR.JOBS, REGIONS, DEPARTMENTS, COUNTRIES, JOB_HISTORY, LOCATIONS, and EMPLOYEES tables',
     attributes =>
      '{"provider": "openai",
        "credential_name": "OPENAI_CRED",
        "object_list": [
            {"owner": "HR", "name": "JOBS"},
            {"owner": "HR", "name": "REGIONS"},
            {"owner": "HR", "name": "DEPARTMENTS"},
            {"owner": "HR", "name": "COUNTRIES"},
            {"owner": "HR", "name": "JOB_HISTORY"},
            {"owner": "HR", "name": "LOCATIONS"},
            {"owner": "HR", "name": "EMPLOYEES"}
        ],
        "max_tokens": 512, 
        "model": "gpt-4o",
        "temperature": 0.1,
        "comments": true
       }');
END;
/
```

Select AI 기능을 SQL로 테스트해봅니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT dbms_cloud_ai.generate(
                    prompt => '매출 현황을 요약해서 보여주세요',
                    action => 'runsql',
                    profile_name => 'ASK_SALES_HISTORY'
                ) FROM DUAL;
```


### 2. MCP(Model Context Protocol) 서버 설정

MCP서버를 구성하기 위하여 Python 라이브러를 설치합니다. 

{% include codeHeader.html copyable="true" codetype="python"%}
```python
pip install fastmcp oracledb
```

Select AI기능을 호출할수 있도록 python 스크립트를 작성합니다.
@mcp.tool() 어노테이션된 함수에 주석을 자세히 작성해야 생성형 AI가 어떤 도구를 사용할지 잘 판단합니다.
select_ai.py로 저장합니다.

두개의 Tools을 제공합니다. 
- ask_profile_list : AI Profile목록을 확인합니다. 
- ask_database : AI Profile이름과 사용자 질문을 질의하여 데이터베이스내에서 데이터를 조회합니다.

{% include codeHeader.html copyable="true" codetype="python" name="select_ai.py"%}
```python
# Import the FastMCP class from the fastmcp module to create an MCP server instance.
from fastmcp import FastMCP

# Import the oracledb module to enable connections to Oracle databases.
import oracledb

# Initialize the FastMCP server with a descriptive name.
mcp = FastMCP("Oracle Database Select AI", dependencies=["oracledb"])

# Define Oracle database connection parameters.
oracle_user = '<DB사용자명>'  # Username for the Oracle database.
oracle_pw = '<DB패스워드>'  # Password for the Oracle database user.
oracle_dsn = "tcps://<dns_name>:1522/<service_name>"  # Data Source Name specifying the Oracle database location.
oracle_wallet_location = '<wallet_location>'  # Path to the Oracle wallet directory.
oracle_wallet_pw = '<wallet_passwd>'  # Password for the Oracle wallet.

@mcp.tool()
def ask_profile_list() -> str:
    """
    Retrieves a list of AI profiles from the Oracle database.

    Connects to the Oracle database using the provided credentials and wallet information.
    Executes a SQL query to fetch all AI profiles, aggregating them into a JSON array.
    Returns:
        A JSON-formatted string containing profile names and their descriptions.
        If no profiles are found, returns a message indicating the absence of profiles.
    """
    # Establish a connection to the Oracle database using a context manager for automatic resource management.
    with oracledb.connect(
        user=oracle_user,
        password=oracle_pw,
        dsn=oracle_dsn,
        wallet_location=oracle_wallet_location,
        wallet_password=oracle_wallet_pw
    ) as conn:
        # Create a cursor object to execute SQL queries.
        with conn.cursor() as cur:
            # Define the SQL query to aggregate profile names and descriptions into a JSON array.
            sql = """
                SELECT JSON_ARRAYAGG(JSON_OBJECT('profile_name' VALUE profile_name, 'description' VALUE description))
                FROM user_cloud_ai_profiles where description is not null and status = 'ENABLED'
            """
            # Execute the SQL query without additional parameters.
            cur.execute(sql)
            # Fetch the first row of the result set.
            result = cur.fetchone()
    # Return the JSON array if profiles are found; otherwise, return a message indicating no profiles exist.
    return result[0] if result else "There is no profile."

@mcp.tool()
def ask_database(user_question: str, profile_name: str) -> str:
    """
    Sends a user question to Oracle Select AI and retrieves the generated response.

    Parameters:
        user_question (str): The question posed by the user to be processed by Select AI.
        profile_name (str): The name of the AI profile to be used for generating the response.

    Returns:
        str: The response generated by Oracle Select AI.
             If no response is generated, returns a message indicating the lack of response.
    """
    # Establish a connection to the Oracle database using a context manager.
    with oracledb.connect(
        user=oracle_user,
        password=oracle_pw,
        dsn=oracle_dsn,
        wallet_location=oracle_wallet_location,
        wallet_password=oracle_wallet_pw
    ) as conn:
        # Create a cursor object to execute SQL queries.
        with conn.cursor() as cur:
            # Define the SQL query to invoke the dbms_cloud_ai.generate function with the user's question and profile name.
            sql = """
                SELECT  json_serialize(dbms_cloud_ai.generate(
                    prompt => :1,
                    action => 'runsql',
                    profile_name => :2
                ) returning CLOB) 
                FROM DUAL
            """
            # Execute the SQL query with the user_question and profile_name as parameters.
            cur.execute(sql, [user_question, profile_name])
            # Fetch the first row of the result set.
            result = cur.fetchone()
            clob_text = result[0].read()
    # Return the generated response if available; otherwise, return a message indicating no response.
    return clob_text if result else "No response from Select AI."

# Entry point of the script.
if __name__ == "__main__":
    # Print a message indicating that the MCP server is starting.
    print("Starting MCP server...")
    # Run the MCP server to start handling requests.
    mcp.run(transport="stdio")
```

### 3. Claude 데스크탑

Claude 데스크탑을 설치하고 아래 파일을 신규로 생성하고 MCP Server를 설정합니다. 
~/Library/Application Support/Claude/claude_desktop_config.json 

{% include codeHeader.html copyable="true" codetype="json" name="~/Library/Application Support/Claude/claude_desktop_config.json"%}
```json
{
    "mcpServers": {
        "select_ai": {
            "command": "<설치위치>/python",
            "args": [
                "<스크립트위치>/select_ai.py"
            ]
        }
    }
} 
```

Claude 데스크탑를 시작하면 자동으로 claude_desktop_config.json 를 읽고, python스크립트를 실행하여 MCP서버를 기동하고 Tools에 등록됩니다. 

{% include video id="L7pUcDtT1cQ" provider="youtube" %} 

사용자가 아래와 같이 질문하였습니다. 

```
우리 회사 직원이 몇명이야?
```

우리 회사에 대한 정보가 없으므로 아래와 같이 답변합니다. 

```
죄송합니다만, 저는 귀하의 회사 직원 수에 대한 정보를 가지고 있지 않습니다. 
저는 귀하의 회사나 조직에 대한 특정 데이터에 접근할 수 없습니다.

귀하의 회사 직원 수를 알기 위해서는 귀하의 회사 내부 자료나 인사 부서에 문의하시는 것이 좋을 것 같습니다. 
혹시 다른 방법으로 도움이 필요하신가요?
```

좀더 구체적으로 Tools를 사용할수 있도록 아래와 같이 질문합니다. 

```
아 그렇구나. 그럼 오라클 데이터베이스에서 우리 회사 직원이 몇명인지 확인해줘
```

Tools정보를 이용하여 AI Profile정보를 가져와서 사용자 질문에 적합한 AI Profile을 설택합니다.
그리고 자연어로 Select AI로 오라클 데이터베이스에 요청합니다. 

```
오라클 데이터베이스에서 회사 직원 수를 확인하기 위해 먼저 사용 가능한 AI 프로필 목록을 확인해 보겠습니다.

select_ai(로컬)의 ask_profile_list 결과 보기
{}[{"profile_name":"ASK_HUMAN_RESOURCE","description":"AI profile that enables querying HR data using HR.JOBS, REGIONS, DEPARTMENTS, COUNTRIES, JOB_HISTORY, LOCATIONS, and EMPLOYEES tables"},{"profile_name":"ASK_SALES_HISTORY","description":"AI profile that enables querying sales trends and performance using SH.SALES, PRODUCTS, COUNTRIES, COSTS, PROMOTIONS, CHANNELS, and TIMES tables"}]

오라클 데이터베이스에 접근할 수 있는 두 개의 AI 프로필이 있습니다:

ASK_HUMAN_RESOURCE: 인사 데이터 조회용 프로필
ASK_SALES_HISTORY: 판매 내역 조회용 프로필

직원 수를 조회하기 위해 인사 데이터 관련 프로필을 사용하여 질문해 보겠습니다.

select_ai(로컬)의 ask_database 결과 보기{
  `profile_name`: `ASK_HUMAN_RESOURCE`,
  `user_question`: `총 직원 수는 몇 명인가요?`
}[{"Total Employees":107}]

인사 데이터베이스 조회 결과, 귀하의 회사 총 직원 수는 107명입니다.
```

제품에 대한 질의를 하였습니다. 

```
오라클 데이터베이스에서 판매한 제품 5개를 확인해줘
```

Select AI기능을 호출하여 답변을 합니다. 

```
오라클 데이터베이스에서 판매된 제품을 확인하기 위해 판매 데이터 관련 프로필을 사용하겠습니다.

select_ai(로컬)의 ask_database 결과 보기{
  `profile_name`: `ASK_SALES_HISTORY`,
  `user_question`: `판매된 제품 5개를 조회해주세요.`
}[{"PROD_ID":13,"PROD_NAME":"5MP Telephoto Digital Camera","PROD_CATEGORY":"Photo","PROD_SUBCATEGORY":"Cameras","PROD_LIST_PRICE":899.99},{"PROD_ID":13,"PROD_NAME":"5MP Telephoto Digital Camera","PROD_CATEGORY":"Photo","PROD_SUBCATEGORY":"Cameras","PROD_LIST_PRICE":899.99},{"PROD_ID":13,"PROD_NAME":"5MP Telephoto Digital Camera","PROD_CATEGORY":"Photo","PROD_SUBCATEGORY":"Cameras","PROD_LIST_PRICE":899.99},{"PROD_ID":13,"PROD_NAME":"5MP Telephoto Digital Camera","PROD_CATEGORY":"Photo","PROD_SUBCATEGORY":"Cameras","PROD_LIST_PRICE":899.99},{"PROD_ID":13,"PROD_NAME":"5MP Telephoto Digital Camera","PROD_CATEGORY":"Photo","PROD_SUBCATEGORY":"Cameras","PROD_LIST_PRICE":899.99}]

오라클 데이터베이스에서 판매된 제품 5개를 조회했지만, 결과가 모두 동일한 제품으로 나타났습니다. 조금 더 다양한 제품을 확인하기 위해 다시 질문해보겠습니다.

select_ai(로컬)의 ask_database 결과 보기{
  `profile_name`: `ASK_SALES_HISTORY`,
  `user_question`: `서로 다른 제품 5개를 조회해주세요.`
}[{"PROD_ID":13,"PROD_NAME":"5MP Telephoto Digital Camera"},{"PROD_ID":14,"PROD_NAME":"17\" LCD w/built-in HDTV Tuner"},{"PROD_ID":15,"PROD_NAME":"Envoy 256MB - 40GB"},{"PROD_ID":16,"PROD_NAME":"Y Box"},{"PROD_ID":17,"PROD_NAME":"Mini DV Camcorder with 3.5\" Swivel LCD"}]

오라클 데이터베이스에서 조회한 서로 다른 판매 제품 5개는 다음과 같습니다:

5MP Telephoto Digital Camera (제품 ID: 13)
17" LCD w/built-in HDTV Tuner (제품 ID: 14)
Envoy 256MB - 40GB (제품 ID: 15)
Y Box (제품 ID: 16)
Mini DV Camcorder with 3.5" Swivel LCD (제품 ID: 17)
```

## 마무리 

MCP를 사용하여 Select AI기능을 생성형 AI에 Tools로 제공하면 생성형 AI가 reasoning과정에서 필요하다고 판단되면 자동으로 사용하게 됩니다. 
데이터베이스내에서 자연어로 데이터를 조회할수 있으로 인터페이스 하는 부분은 매우 간단하다는것을 알수 있습니다. 
AI Agent에 다양한 Tools로써 Oracle Database Select AI를 사용하면 보다 개인화된 정보를 기반으로 정교한 답변을 기대해볼수 있을것 같습니다. 
