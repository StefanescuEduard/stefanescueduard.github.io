---
title: JWT Authentication with Asymmetric Encryption using certificates in ASP.NET Core
date: 2020-04-25 20:15:56
tags:
  - authentication
  - dotnetcore
  - asp
  - asymmetric
  - encryption
---

<!-- markdownlint-disable MD033 -->

In the previous article I wrote about JWT Authentication using a single security key, this being called Symmetric Encryption. The main disadvantage of using this encryption type is that anyone that has access to the key that the token was encrypted with, can also decrypt it. Instead, this article will cover the Asymmetric Encryption for JWT Token.
In the first part of this article, the Asymmetric Encryption concept will be explained, and in the second part, there will be the implementation of the JWT Token-based Authentication using the Asymmetric Encryption approach by creating an "Authentication" Provider in ASP.NET Core.

## Introduction

The JWT Token concepts were explained in the previous article, so if you want to find more before continuing reading this article, check out the introduction of the previous one: <https://stefanescueduard.github.io/2020/04/11/jwt-authentication-with-symmetric-encryption-in-asp-dotnet-core/#Introduction>.
Asymmetric Encryption is based on two keys, a public key, and a private key. The public key is used to validate, in this case, the JWT Token. And the private key is used to sign the Token. Maybe the previous statement is a little bit fuzzy, but I hope that will make sense in a moment.
{% zoom asymmetric-key.svg %}
For using the Asymmetric Encryption, two keys have to be generated, these two keys have to come from the same root. In this case for this article there will be a certificate &ndash;&ndash; the root &ndash;&ndash; from which the private and the public key will be generated. These keys will be also certificates, so the first thing that has to be done is to generate the private certificate &ndash;&ndash; key &ndash;&ndash; and the second one to generate the public certificate &ndash;&ndash; key &ndash;&ndash; from the private certificate.

## Generating the keys

To generate certificates I chose to use the OpenSSL toolkit. If you are on Windows, OpenSSL can be downloaded as an executable and installed where ever you want. I recommend being installed on the C:\ root.
OpenSSL download link: <https://slproweb.com/products/Win32OpenSSL.html>
The tool has to be used from the Terminal, so there are two choices:

1. Run the executable from where the tool was installed.
2. Add an environment variable to have access to it from everywhere as a CLI.

To add the tool as an environment variable the following entry has to be inserted to the User variables:
<pre>
  Variable name: OPENSSL_CONF
  Variable value: &lt;PATH_TO_OPEN_SSL&gt;\bin\cnf\openssl.cnf
</pre>
After configuring OpenSSL, the private and public key have to be generated using the following commands:

- For the private key: `openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048`
  - `genpkey` specifying that we'll generate a private key;
  - `-algorithm RSA` the algorithm used, in this case RSA;
  - `-out private_key.pem` the output argument and path;
  - `-pkeyopt rsa_keygen_bits:2048` set the public key algorithm and the key size;
- For the public key: `openssl rsa -pubout -in private_key.pem -out public_key.pem`
  - `rsa` specifying that the command will process RSA keys;
  - `-pubout -in private_key.pem` the private key and the path of it;
  - `-out public_key.pem` the output argument and path;
  
Before starting into code, the generated PEM keys have to be converted into XML files. That was the easiest way to read them using the `System.Security.Cryptography` package.
To convert them into XML you can use this site: <https://superdry.apphb.com/tools/online-rsa-key-converter>, then copy the converted text into two files with the XML extension in the project folder.

The Setup is the same as in the previous article, so check it out here: <https://stefanescueduard.github.io/2020/04/11/jwt-authentication-with-symmetric-encryption-in-asp-dotnet-core/#Setup>. TL;DR you have to install the following package: `Microsoft.AspNetCore.Authentication.JwtBearer`.

## `Startup`

As in the previous article, the Authentication service has to be added in the `ConfigureServices` method from the `Startup` class. For Authentication, an extension method called `AddAsymmetricAuthentication` will setup the service with the basic settings.
It may be a little bit confusing to switch between this and the previous article, but the only thing that is changed here compared to the previous article is the `IssuerSigningKey` property, which now receives the `SigningKey`. The previous article contains a comprehensive explanation of each property that it's used: <https://stefanescueduard.github.io/2020/04/11/jwt-authentication-with-symmetric-encryption-in-asp-dotnet-core/#Startup>.

The `SigningIssuerCertificate` is used to get the `IssuerCertificate` or the public key; I will return to this class in a moment. The code below contains only what is necessary to use the public key in the Authentication service.
<script src="https://gist.github.com/StefanescuEduard/4671d82a5b710017313b45f0b7dbd0af.js"></script>

After the `Authentication` service was added, in the `Configure` method the `Authorization` and `Authentication` middleware needs to be added to the pipeline.
<script src="https://gist.github.com/StefanescuEduard/3b7f8d14b342b24609d32d519976d391.js"></script>

## `SigningIssuerCertificate`

In this class, the RSA class is used to create a `RsaSecurityKey` with the public key generated before.
<script src="https://gist.github.com/StefanescuEduard/c766ed9e3e9ac416c8f483e088840f0d.js"></script>
`FromXmlString` initializes the `rsa` object with parameters from the XML files.
<!-- markdownlint-disable no-bare-urls -->
If we dig down in this method &ndash;&ndash; https://git.io/JvbVm &ndash;&ndash; we can see that the `RSAParameters` are the same as they are in the XML file converted before.

The `rsa` is created on the constructor, this object must be disposed because there might be some resources that will run after the process ends.
<script src="https://gist.github.com/StefanescuEduard/e104237af473b67124c0c6cf2cfe79c4.js"></script>

## `SigningAudience Certificate`

`SigningAudienceCertificate` is very similar to the `SigningIssuerCertificate`, the only differences are that, is using the private key to initialize the `rsa` object and is returning `SigningCredentials` constructed with the `RsaSecurityKey` and the `SecurityAlgorithms`. For this, the `RsaSha256` algorithm is used because is the most recommended one. If you want to find what algorithm to use for each type of encryption, check out this article: <https://auth0.com/blog/json-web-token-signing-algorithms-overview/>.
<script src="https://gist.github.com/StefanescuEduard/1dadcc525127a60f62e8b0b19f8abf46.js"></script>

## `AuthenticationService`

This service is used by the `AuthenticationController` to authenticate the user. It is like a middleware because it's using the `UserService` to validate the received `UserCredentials` and the `TokenService` to generate the JWT Token if the credentials were valid.

The `UserService` and `UserCredentials` were created in the previous article so I will use them from there. The `UserService` is a more likely a mock service, that has an internal list of users and checks if the given credentials are on that list. And the `UserCredentials` contains two properties `Username` and `Password`.
<script src="https://gist.github.com/StefanescuEduard/fc8c8776b5b10c235d0ec90a03baddf3.js"></script>

## `TokenService`

`TokenService` initializes on the constructor the `SigningAudienceCertificate` class created before. With this object, the `SigningCredentials` for the `TokenDescriptor` will be created.
<script src="https://gist.github.com/StefanescuEduard/7ca742437c69dc1cfb04cc31587b74d2.js"></script>

The `GetToken` method is used to generate the `TokenDescriptor` by using the `GetTokenDescriptor` method that will be explained in a moment; to create a `SecurityToken` from that descriptor and to get the token as a string from that object.
<script src="https://gist.github.com/StefanescuEduard/915e50db78f2ca12eaa67063e760abf1.js"></script>

`GetTokenDescriptor` method creates a token with the minimum required properties: `Expires` and `SigningCredentials`. Also, the `Expires` property here is used because on the `Authentication` method the `LifetimeValidator` was set, but it doesn't need to be specified.
All `SecurityTokenDescriptor` properties can be found on the Microsoft website: <https://docs.microsoft.com/en-us/dotnet/api/microsoft.identitymodel.tokens.securitytokendescriptor>.
The `GetAudienceSigningKey` method created before is used to generate the Token `SigningCredentials`, to validate that the Token was signed with the same private key from which the public key was generated.
<script src="https://gist.github.com/StefanescuEduard/207fc69fd317387a32581f83506fc04b.js"></script>

## `AuthenticationController`

In the `AuthenticationController` an endpoint is created to authenticate the user with `UserCredentials` and get the JWT Token by using the `AuthenticationService` described earlier.
<script src="https://gist.github.com/StefanescuEduard/6c177445d14a723ac78abf737a1c2b80.js"></script>

## `ValidationController`

And the `ValidationController` contains a plain endpoint that it's using the `Authorize` attribute to validate the Token. Note that the Authentication Scheme must be used on the Authorize attribute and for the Authentication service.
<script src="https://gist.github.com/StefanescuEduard/800e5b2315d5086c47b58dc3bb74a7dc.js"></script>

## The result

### Authentication

Firstly the Authentication happy flow will be tested, so the combination of the username and password will match and the endpoint should provide the generated Token.
{% zoom authorized-authentication.png %}
And secondly let's test the unauthorized flow, where the provided credentials are wrong.
{% zoom unauthorized-authentication.png %}

### Validation

Before checking that the Token is valid using the `ValidationController`, Auth0 crafted <https://jwt.io/> that decode the Token and check whether or not the Token is valid.
{% zoom jwt-token-validation.png %}
On the Verify Signature section, both keys must be entered to validate the signature of the certificate.
Now the `ValidationController` will be used to check whether the token is valid or not, but this will happen internally, on the Authorize attribute. Firstly, the happy flow.
{% zoom valid-token.png %}
And in the second test, the wrong token is validated.
{% zoom invalid-token.png %}

---

The source code from this article can be found on my GitHub account: <https://github.com/StefanescuEduard/JwtAuthentication>.

Thanks for reading this article, if you find it interesting please share it with your colleagues and friends. Or if you find something that can be improved please let me know.
