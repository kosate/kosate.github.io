---
layout: single
title: Spring Boot에서 basePackageClasses를 이용하여 @ComponentScan하기
date: 2022-05-11 22:01
categories: 
    - backend
tags: 
    - spring-boot
    - component-scan
excerpt : '@ComponentScan시 basePackageClasses을 사용하면 하위 패키지에서 상위 패키지에 있는 @Component들을 읽을수 있습니다.'
toc : true
toc_sticky: true
---

@ComponentScan 어노테이션 동작방식
-

Spring에서는  @ComponentScan을 사용할 경우 **@ComponentScan 어노테이션이 선언된 클래스의 패키지**부터 scan을 시작합니다. basePackageClasses() or basePackages() 을 사용할 경우 scan의 위치를 지정할수 있습니다. 

```java
@ComponentScan(basePackages = "com.example1.project1.service") 
```
> basePackages를 사용할 경우 설정된 패키지부터 scan을 수행합니다. 그러나 string값으로 패키지를 지정하므로 값을 잘못설정하면 scan을 오류가 발생될수 있습니다. 

```java
@ComponentScan(basePackageClasses = com.example1.project1.service.exampleTest.class) 
``` 

> basePackageClasses을 사용할 경우 지정된 class에 있는 패키지부터 scan을 수행합니다. class명를 직접 지정하여 소스관리(Refactoring, typesafe)가 용이합니다. 


Component Scan되지 못했을때 발생되는 에러
-

여러개의 Spring boot 프로젝트를 만들고, 
프로젝트간에 참조가 될경우 패키지들이 뒤죽 박죽이 되어 Component Scan할때 NoClassDefFoundError 에러가 발생될수 있습니다.

### 코드 예시

> 예시 - "주문"프로젝트   
> - com.example1.project1.service  
>   - 주문서비스.java  

> 예시 - "상품"프로젝트  
> - com.example3.project2.service  
>   - 상품서비스.java  

> 예시 - "배송"프로젝트  
> - com.example2.project3.service  
>   - 배송서비스.java  
> - com.example2.project3.service.example  
>   - 배송서비스테스트.java   

"배송"프로젝트에 있는 "배송서비스테스트" 클래스에서 "주문", "상품", "배송"프로젝트에 있는 Service를 이용하여 테스트할경우, 각 프로젝트의 Service들은 Component Scan되어 Bean으로 저장되어 있어야합니다. 하지만 하위패키지에서 @ComponentScan하면 상위 패키지를 검색하지 않기 대문에 NoClassDefFoundError에러가 발생될수 있습니다. 


basePackageClasses사용하여 해결
--

Component Scan을 위하여 각 프로젝트에 있는 최상위 패키지에 임의 클래스하나를 생성하고 basePackageClasses에 해당 클래스를 지정하여 component Scan시 상위 패키지에 있는 Component들을 scan하도록 합니다.

### 코드 예시
각 프로젝트 별로 최상위 패키지에 **내용이 비어 있는 Interface or Class** 생성합니다. 

> 예시 - "주문"프로젝트 
> - com.example1.project1
>   - Project1BaseClass.java (신규 생성)

> 예시 - "상품"프로젝트
> - com.example3.project2
>   - Project2BaseClass.java (신규 생성)

> 예시 - "배송"프로젝트
> - com.example2.project3
>   - Project3BaseClass.java (신규 생성)

배송서비스테스트.java에서 아래와 같이 코드를 작성할수 있습니다.

```java
package com.example2.project3.service.example

import com.example1.project1.Project1BaseClass
import com.example3.project2.Project2BaseClass
import com.example2.project3.Project3BaseClass

@SpringBootApplication 
@ComponentScan(basePackageClasses ={
    Project1BaseClass.class,
    Project2BaseClass.class,
    Project3BaseClass.class})
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
		배송서비스테스트 runner = context.getBean(배송서비스테스트 .class);
		runner.run();
	}
}
```

