---
title: .NET Core Code Coverage
date: 2020-02-22 14:23:39
tags:
  - .net core
  - code coverage
---

Code coverage tools are a great way to improve the code quality, but there are a lot of tools that require a paid license to use it like dotCover, the Enterprise version of Visual Studio or Visual Studio extensions. After some research, I found out that two free tools that combined can generate code coverage reports. The first tool is called [Coverlet](https://github.com/tonerdo/coverlet) which generates the code coverage as I wanted and it's also working with .NET Framework. Essentially is creating an `XML` report file that covers the lines, branches, and methods. And the second tool is [ReportGenerator](https://github.com/danielpalme/ReportGenerator) which is used for parsing the generated `XML` and expose the data in a friendly format.

For this article, I created a small project to demonstrate how is working.
Let's begin with the Business layer; which contains two classes, a dummy `User` that only has two properties `Roles` and `ManagedCountries`.

<script src="https://gist.github.com/StefanescuEduard/dcbeb1fcdaa4e019c9764ab5ec8df0fb.js"></script>

And a `UserService` that checks if the `User` has sufficient rights to delete a country.

<script src="https://gist.github.com/StefanescuEduard/6e13369330c8e1a32d424da04d94ba2e.js"></script>

I know that the return of the `CanDeleteCountry` method can be simplified, but I will keep as it is, just for the sake of this example.

The Tests project uses `NUnit`, but I saw that `Coverlet` and `ReportGenerator` also work with `MSBuild` and `xUnit`, for those you only need another TestAdapter and TestLogger. The packages installed for this project are:

- [NUnit](https://www.nuget.org/packages/NUnit)
- [NUnit3TestAdapter](https://www.nuget.org/packages/NUnit3TestAdapter)
- [NunitXml.TestLogger](https://www.nuget.org/packages/NunitXml.TestLogger)
- [Microsoft.NET.Test.Sdk](https://www.nuget.org/packages/Microsoft.NET.Test.Sdk)
- [Microsoft.CodeCoverage](https://www.nuget.org/packages/Microsoft.CodeCoverage)
- [coverlet.msbuild](https://www.nuget.org/packages/coverlet.msbuild)
- [ReportGenerator](https://www.nuget.org/packages/ReportGenerator)

In order to get the code coverage, a script is needed that will run the tests, create the `XML` file report and generate an `HTML` file with the reports.

<script src="https://gist.github.com/StefanescuEduard/d7b91fa0c49c422b22b5911de2bd9566.js"></script>

I've created a batch file to be more easy to run all the commands in a single unit. Also please note that if you are using Mac or Linux, the `nuget` packages path, it would be: `~/.nuget/packages`.
The first command will run the tests and will generate the `XML` file used by the second command to generate the report. And the third command will open `index.html`.
Please consider adding the `Coverage` folder into `.gitignore` if you are working on a team, this is just for local purposes and it would be nice if the project you are working on has on the CI build process a step where the code coverage is generated.

So now, with all that in place, let's see the results. I wanted to test only if the `User` is not a `CountryManager` and skip the other conditions that will also check for the managed countries because I wanted to generate a report with all the available covered areas.

<script src="https://gist.github.com/StefanescuEduard/efe808ad09dfbbd596fcc7afc2219f76.js"></script>

Let's take a look at the code coverage report. When the `index.html` file is open, the first page contains an overview of the ran tests, it offers a brief summary of the report and a grouping feature, that can be used to view the files on different layers (i.e. No grouping, By assembly, By namespace, Level: 1 and By namespace, Level: 2).
{% zoom code-coverage-overview.png Code coverage overview %}
The test report for `UserService` class looks something like this:
{% zoom code-coverage-user-service-class.png Code coverage of UserService class %}
The color code is the same as in the other tools, but what I like is that it also have the branch coverage, which in the above picture is the yellow area.

In conclusion, these two tools are great and don't cost anything, also can be configured to run through all test projects and generate more comprehensive code coverage.

Here is the repository link with all the code from this article: https://github.com/StefanescuEduard/AspNetCoreCodeCoverage. I kept the Coverage folder on the repository just for testing purposes.

Thanks for reading this article, if you find it interesting please share it with your colleagues and friends. Or if you find something that can be improved please let me know.
