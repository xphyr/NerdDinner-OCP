# NERDDINNER OCP Example

This repo is a demo of taking an older MVC application and running it in a WINDOWS Container hosted in OpenShift using Windows Worker Nodes.

[NerdDinner](https://learn.microsoft.com/en-us/aspnet/mvc/overview/older-versions-1/nerddinner/introducing-the-nerddinner-tutorial) was originally hosted on CodePlex. I have made a copy of the code from [https://github.com/sixeyed/nerd-dinner](https://github.com/sixeyed/nerd-dinner) and am using this as the basis of this project. The C# code has not been changed at all from Sixeyed's copy of the code, which is listed as being an original copy of the code.

The intent is to show that using Windows containers it is possible to run code that goes back a few years.

## Requirements

* Visual Studio 2022
* OpenShift Container Platform 4.12+
	* Windows Machine Config Operator installed and working
* Windows 11 Machine with Windows Containers configured

## Building the Container

This example is written and tested using the mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2022 base container.