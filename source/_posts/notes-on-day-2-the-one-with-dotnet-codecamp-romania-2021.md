---
title: Notes on Day 2 - The One with Dotnet @Codecamp Romania, 2021
date: 2021-04-02 10:24:22
tags: 
- dotnet
- conference
- codecamp
---

There was a small talk when Raffaele told us what he did in this corona time. So he started working with ML and also Code Generation driven by ML.

There was also a talk about how ML was involved in the industry. For example, every machine now starts having more user-friendly interfaces and through this more things can be automated to provide a much greater experience to end customers. And also to the factories that can apply ML to simulate a result before creating and applying those concepts.

## Power your .NET application with the new generation of diagnostics - March 25 14:00 - 14:45 - Raffaele Rialdi

The session goal was to show how to automate the diagnostic process in production.

The first step was when to trigger a diagnostic with the DiagnosticClient library. And the second step was that once the data was captured, we can programmatically analyze the process that gave the problem with ClrMD 2.0 library.

Preemptive profiling or microbenchmark is used on dev machines to analyze specific lines of code that are not performing as expected, by using Benchmark.NET.

In production, the primary source of help are the logs. But those logs should not be too verbose but also not too short, for example containing too little information.

A dump can be a solution by using for example dotnet-dump, but it is not a tool for investigating problems, because the problem can be done after analyzing it, and catching the perfect moment is hard.

In production, the performance can be monitored with dotnet-trace, dotnet-counter and in .NET 5 we can use a new tool dotnet-monitor that can connect to remotely located and locally we can access it through a web interface.

There is also another problem with dumps because there might be sensitive data, for example, the application could be installed in a hospital, so those data can be constrained by privacy and EU regulation like GDPR.

The presented scenario was an [ASP.NET](http://asp.NET) Core application and many clients that use the app. There is also a console application used to stress the web service, that can make concurrent requests. The diagnostic application is receiving TraceEvents from the web service. This application uses two libraries: DiagnosticClient and ClrMD 2.0 (the investigating library, that grabs data). When an issue occurs a snapshot with the web service is created by this diagnostic app. By doing so we can capture the exact moment when the problem occurred.

The communication between web service and diag app is the communication that can be made with every .NET application starting with .NET Core 3.0.

The library recommended is [https://github.com/raffaeler/PowerDiagnostics](https://github.com/raffaeler/PowerDiagnostics). 

Diagnostic Demo app was used to capture snapshots and also run different queries to display the root cause of the problem. For example, discovering a big byte array that uses too much memory. Or querying duplicate strings, getting strings by size, list of modules or threads stacks.

The app can also load a dump saved before and that dump can be investigated as dump saved at the runtime.

.NET 5 introduces reversed communication protocol, which can be used to diagnose apps, like subscribing to them and when an event occurs, the diagnosis app can read them.

## The (too) Many Faces of Architecture - March 25 15:00 - 15:45 - Mihaela Ghidersa

This presentation was a generic one about architecture, discussing different types of architecture.

Architecture is a technical solution that makes artistic or more abstract concepts materialize.

In the real world, architecture is creating a small module and combining both technical and business concepts into a big schema or structure.

The architecture can be seen as a blueprint. We should define what and why is significant.

The architect is not about the title, he or she has a flexible role, that can collaborate more than giving indications.

{% zoom Untitled.png %}

## Telemetry in .NET distributed applications - March 25 16:00 - 16:45 - Constantin-Ariton Lazar  /  Mihai Detesan

The presentation was focusing on automotive telemetry by using Bosch sensors. 

There was a comparison between the Monolith application and the new way of developing products with microservices.

One of a problem with microservices is with the coherence, which can be difficult to track because each microservice creates request between them. And for example, if an error occurred is a bit hard to know from where it comes.

And also another problem comes from debugging and is also difficult to locate.

In monolith application scaling represents adding more hardware resources, instead of on microservices scaling represents adding more instances of a specific or many microservices.

The "telemetry" word comes from Greek, tele = distance and metron = measure. The "sum" of this to words can be translated as a process of recording and transmitting some logs or reading of a sensor or even a machine.

OpenTelemtry is an observability framework that combines traces and metrics.

Jaeger and Zipkin were used for tracing.

To trace all microservices, each of them has a Trace Id that uniquely identifies each microservice.

The trace collector creates some sort of graph from all traces.

All the Trace IDs are sent from a microservice to another when creating a request, to know which microservice called another one.

The final id is composed of the Trace Id and the Parent Id.

Elasticsearch was used to store the logs with Timestamp, Service context like IP or the microservice name, the operation context like the stack trace, and the Trace Id.

## What's New in C# - March 25 17:00 - 17:45 - Chris Sienkiewicz  /  Fred Silberberg

In C# there are top-level statements, before declaring usings, namespace, and declaring classes. And those lines are executed. The compiler will take it and put it in a form to execute it.
Even async calls will work in top-level statements because the main method that runs these lines is an async one.
For not including the namespace in the statements we can use using before them.
In top-level statements functions can also be declared. But the functions can be used only in the local top statements. So for example, if there are classes under, those top functions can't be called in. 

{% zoom Untitled1.png %}

Because var fields can't be used for declaring fields at the class level. Now those fields can be instantiated only by calling *new()*.

{% zoom Untitled2.png %}

The new keyword can also be used to instantiate a class without specifying the name.

{% zoom Untitled3.png %}

To avoid overriding the not equal operator (!=) when checking for null, we can verify an object that is not null, by using exactly those keywords "is not null".

{% zoom Untitled4.png %}

When comparing two objects to avoid overriding the Equals method, the class can be changed to a record, that represents a class type with value semantics, compares equality by value. This works only to type fields.
A record can be seen as a collection of values.

There is a new future called initialization only available only to *record*, which provides the ability to assign a property only once in the object initialization.

The *with* keyword provides non-destructive mutation, that creates a copy of the variable. So values can be set as a part of the initialization.

{% zoom Untitled5.png %}

Records offer the possibility to add a property at the declaration level, similar to the constructor.

{% zoom Untitled6.png %}

And the inheritance looks very similar to the constructor, without using the base keyword.

{% zoom Untitled7.png %}

In C# 10 there can be some of the following futures:

The namespaces can be declared without braces.

The global keyword can be used with using to declare a variable or a namespace in a single place. This will make those declarations available all over other files.

Nullable types can be used in if.

There can be semi-auto properties that have a backing field, that doesn't need to be declared.

The records can be also structs (record struct), similar to the current record for classes.

There can be required properties that uses the *required* keyword that requires the user to set it. 

The IAddable interface can be used to "override" the plus sign to perform add operation with which type is needed. 

## Recipe for Modern Applications: .NET, Azure SQL, Functions, Geospatial, JSON - March 25 18:00 - 18:45 - Anna Hoffman

The presentation was about creating an application to be notified when a bus arrives.

The data are imported from the public transportation data. Azure was used for all the below "pieces".

{% zoom Untitled8.png %}

For the database, Azure SQL Database was used because it has the multi-model capability and also native geospatial support. And another important point of using Azure SQL Database is the feature of using JSON because the conversion is done automatically (from non-relational to relational).

Azure Data Studio looks very similar to Jupiter used for Python. It is a notebook where both code (SQL, Powershell) and documentation can be written.

There are geofences created to be notified when the bus enters them.

Overall, this was my first Code camp conference and also my first conference online. It was a nice experience, but it is not compared with a real-life conference, where you can see the presenters and even ask them questions after the session.
But if the corona still stays among us, these conferences are a great way to refresh your mind with what's new in technology and in .NET.