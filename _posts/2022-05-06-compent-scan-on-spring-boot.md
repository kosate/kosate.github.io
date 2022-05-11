---
layout: single
title: Spring Boot에서 basePackageClasses를 이용하여 @ComponentScan하기
date: 2022-05-06 22:01
category: Spring-boot
author: kosate@gmail.com
tags: ['spring-boot','component-scan']
summary: '@ComponentScan시 basePackageClasses을 사용하면 하위 패키지에서 상위 패키지에 있는 @Component들을 읽을수 있습니다.'
toc : true
comments: true
---

(테스트중입니다.)


Spring Boot에서 basePackageClasses를 이용하여 @ComponentScan하기
===

@ComponentScan시 basePackageClasses을 사용하면 하위 패키지에서 상위 패키지에 있는 @Component들을 읽을수 있습니다.
---

여러개의 Spring boot 프로젝트를 만들고, 
프로젝트간에 참조가 될경우 패키지들이 뒤죽 박죽이 되어 Component Scan할때 NoClassDefFoundError 에러가 발생될수 있습니다.


> 예시 - "주문"프로젝트 
    - com.example1.project1.service
    - 주문서비스.java

> 예시 - "상품"프로젝트
    > com.example3.project2.service
    >  상품서비스.java

> 예시 - "배송"프로젝트
    > com.example2.project3.service
    > 배송서비스.java
    > com.example2.project3.service.example
    > 배송서비스테스트.java 

"배송"프로젝트에 있는 "배송서비스테스트" 클래스에서 "주문", "상품", "배송"프로젝트에 있는 Service를 이용하여 테스트할경우, 각 프로젝트의 Service들은 Component Scan되어 Bean으로 저장되어 있어야합니다. Component Scan을 위하여 각 프로젝트에 있는 최상위 패키지에 임의 클래스하나를 생성하고  Spring boot실행 클래스에서 basePackageClasses이용하여 Component Scan할경우 상위 패키지에 있는 Component들을 bean으로 관리하여 정상적으로 수행됩니다. 

 예시 - "주문"프로젝트 
    > com.example1.project1
    > Project1BaseClass.java

> 예시 - "상품"프로젝트
    > com.example3.project2
    > Project2BaseClass.java

> 예시 - "배송"프로젝트
    > com.example2.project3
    > Project3BaseClass.java


```java
package com.example2.project3.service.example

@SpringBootApplication 
@ComponentScan(basePackageClasses ={Project1BaseClass.class,Project2BaseClass.class,Project3BaseClass.class})
@Component 
public class 배송서비스테스트 {
    @autowired
    private 주문서비스 aservice;
    @autowired
    private 상품서비스 bservice;
    @autowired
    private 배송서비스 cservice;
    
    public void run(){
       // To do aservice...
       // To do bservice..
       // To do cservice...
    }
    public static void main(String[] args) {
		ApplicationContext context = SpringApplication.run(배송서비스테스트.class, args);
		Test runner = context.getBean(배송서비스테스트 .class);
		runner.run();
	}
}
```

