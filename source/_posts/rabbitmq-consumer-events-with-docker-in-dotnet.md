---
title: RabbitMQ Consumer Received Event with Docker in .NET
date: 2020-04-04 16:30:20
tags:
  - rabbitmq
  - amqp
  - consumer
  - docker
  - dotnetcore
---

This article contains another approach of consuming messages. The first part will be a comparison between the several types of consuming messages and in the second part, each line of code will be explained.
The entire environment setup with Docker can be found in the first article from the RabbitMQ series. In this series, there are also explained some core principles about each RabbitMQ node. I highly recommend that, if you are at the beginning with RabbitMQ or with the AMQP standard, to start with these articles:
1. https://stefanescueduard.github.io/2020/02/29/rabbitmq-producer-with-docker-in-dotnet/
2. https://stefanescueduard.github.io/2020/03/07/rabbitmq-exchange-with-docker-in-dotnet/
3. https://stefanescueduard.github.io/2020/03/14/rabbitmq-queue-with-docker-in-dotnet/
4. https://stefanescueduard.github.io/2020/03/21/rabbitmq-consumer-with-docker-in-dotnet/

## Introduction

The RabbitMQ Client provides a `Received` event that will be used to consume the messages coming from one or more `Queues`. In the `Consumer` article, the messages are consumed and acknowledged using the `BasicGet` and the `BackAck` methods in a while loop, waiting for the `CancellationToken`. The advantage of that method is that a message can be consumed when needed. So, care must be taken when using this method. It's not recommended to use it in an infinite while loop if the `Received` event exists, and it's a good replacement for that type of approach.
The advantage of the `Received` event is obvious, that will no longer consume unnecessary resources, but the "disadvantage" is that the messages will be consumed whenever they are raised based on the `routing key`.
But this depends on the different scenarios which way to choose. A useful tip that may help when you must choose between these two ways of consuming messages is:
- `BasicGet` method can be used when there are more messages to get or it needs to be consumed at a certain time;
- `Received` event can be used when the raised message needs to be consumed immediately;

There is also another approach to consume messages, by inheriting the `DefaultBasicConsumer` class. This gives the advantage of having a hierarchy of consumers, which may lead to different design patterns.

In the following part of this article, there will be only some chunks of code, which are required to consume the messages using the `Received` event. The connection setup is the same as in previous articles.

## `Received` event

Before start establishing the connection, a `CancellationToken` is needed to wait for the user to stop the Console App execution.

To bind the `Consumer` to the `Channel`, a new `EventingBasicConsumer` instance is made by passing the `Channel` as parameter.
<script src="https://gist.github.com/StefanescuEduard/e2c8b47c6acdbd68d1b1250053417f76.js"></script>

An important note here is that there is no need to surround the `IConnection` and the `IChannel` into a using statement, the reason for this is that the `Connection` and the `Channel` need to exist as long as the app. If these two variables were disposed too early, then no message would be received.
You may notice that in this RabbitMQ series, I used the `Channel` word instead of the official name `Model`, that's because it's easier to understand. For me, a `Model` is too generic, instead, a `Channel` makes me think to a communication channel, which in fact it really is.
The official documentation for `EventingBasicConsumer` can be found here: https://www.rabbitmq.com/releases/rabbitmq-dotnet-client/v3.1.1/rabbitmq-dotnet-client-3.1.1-client-htmldoc/html/type-RabbitMQ.Client.Events.EventingBasicConsumer.html.

### Subscribing to the event

Using the `Consumer` created earlier, we subscribe to the `Received` event the `OnNewMessageReceived` handler.
<script src="https://gist.github.com/StefanescuEduard/f52c65f4e85caab49614b6072a94b25c.js"></script>

### Handling the event

This event handler will display the received message and another message to inform the user that can stop consuming messages.
<script src="https://gist.github.com/StefanescuEduard/7bedd0d607840b0b7f25a5bc92413e46.js"></script>

### Consuming messages

To start consuming messages, the `Consumer` will be bind to the queue. In the following code, there is an iteration through the queues count entered previously. Then the user is asked to enter the `Queue` name that will be bound to the `Consumer`.
The `BasicConsume` method takes three parameters:
- the first one is the `Queue` name;
- the second is used for auto acknowledgment, in this case, is set to `true`, but if it was set to `false` then the acknowledgment had to be done manually if this is wanted;
- and the third one is the `Consumer`;

### Waiting for `Cancellation`

The `WaitHandle` static class is a handy way to wait for the `CancellationToken` to be raised. Instead of the `CancellationToken`, the `AutoResetEvent` or other signaling events can be also used.
<script src="https://gist.github.com/StefanescuEduard/1fdd2c18bee80962677a720eddbce303.js"></script>

### Disposing resources

After the user indicates that no longer wants to receive messages, or in a real-life scenario, when the application ends, all the created resources need to be disposed.
<script src="https://gist.github.com/StefanescuEduard/be8d01bb086ce8331d780cfb5ca6a499.js"></script>

Firstly the `OnNewMessageReceived` event handler needs to be unsubscribed from the `Received` to stop displaying messages after the program finishes its execution. It can be possible that reference to event handler can still exist after the resources are disposed and the program closes. So, I highly recommend that all the time when it's needed, to unsubscribe the event handlers.
After that, the `Channel` and the `Connection` are closed and disposed.

### The result

Using the `Producer`, the direct `Exchange` and one `Queue` created in the previous articles, the topology will be created and the `Consumer` will be connected to it.
In the picture below, the sent message by the `Producer` using a specific `routing key` bound to the `Queue` reached the event handler, and this displayed the message.

{% zoom consumer-received-message.png Consumer received message %}

---

All the code for this `Consumer` and for the entire topology is available on my GitHub account: https://github.com/StefanescuEduard/RabbitMQ_POC

Thanks for reading this article, if you find it interesting please share it with your colleagues and friends. Or if you find something that can be improved please let me know.

<a href="https://www.buymeacoffee.com/edstefanescu" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>