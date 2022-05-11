---
layout: single
title: NextAuth.js로 카카오인증하기
date: 2022-05-10 21:58
category: 
  - Frontend
author: 
tags: ["React", "Next.js","NextAuth.js","Kakao","authentication","TypeScript","Signin","Signout","Session"]
summary: 
toc : true
---

(테스트중입니다.)

환경 

yarn create next-app todayevent
yarn add --dev typescript @types/react @types/node

type 스크립트 설정
https://noogoonaa.tistory.com/65


Authentication
https://next-auth.js.org/
npm install --save next-auth



```javascript
import NextAuth from "next-auth";
import KakaoProvider from "next-auth/providers/kakao";

export default NextAuth({
    providers:[
        KakaoProvider({
            clientId: process.env.KAKAO_CLIENT_ID,
            clientSecret: process.env.KAKAO_CLIENT_SECRET
        })
    ],
    callbacks: {
        async signIn({ user, account, profile, email, credentials }) {
            console.log(`signIn - user - ${user} , account - ${account} `)
          return true
        },
        async redirect({ url, baseUrl }) {
            console.log(`redirect - url - ${url} , baseurl - ${baseUrl} `)
          return baseUrl
        },
        async session({ session, user, token }) {
            console.log(`session - session - ${session} , user - ${user} , token -  ${token}`)
          return session
        },
        async jwt({ token, user, account, profile, isNewUser }) {
            console.log(`jwt - token - ${token} , user - ${user} , account -  ${account} , profile -  ${profile} , isNewUser -  ${isNewUser}`)
          return token
        }
    },
})
```
```javascript
import { AppProps } from 'next/app'
import { SessionProvider}  from 'next-auth/react'

function App({ 
    Component, 
    pageProps : {session, ...pageProps},
 }: AppProps) {
  return (
    <SessionProvider session={session}>
      <Component {...pageProps} />
    </SessionProvider>
  )
}

export default App
```



```javascript
import React, { useState } from "react";
import Head from "next/head";
import Component from "../src/component/auth/login-btn";

export default function Home() {

  return (
    <div className="container"> 
      <Component/>
    </div>
  );
}
```


카카오 개발자 사이트에가서 앱생성하고 client 및 rest_api secret 만들기

https://developers.kakao.com/

```text
NEXTAUTH_URL=http:/localhost:3000/api/auth
KAKAO_CLIENT_ID=xx
KAKAO_CLIENT_SECRET=xx
NEXTAUTH_SECRET=xx
```


== 테스트 결과 ==


--
부록..

아래와 같은 에러가 발생될때.
[next-auth][warn][NO_SECRET] 
https://next-auth.js.org/warnings#no_secret
https://next-auth.js.org/configuration/options#secret