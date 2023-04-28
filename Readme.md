# NERDDINNER OCP Example

This repo is a demo of taking an older MVC application and running it in a WINDOWS Container hosted in OpenShift using Windows Worker Nodes.

NerDinner was originally hosted on CodePlex, but with the shutdown of CodePlex, I am using someones copy of the code. I have made a copy of the code from [https://github.com/sixeyed/nerd-dinner](https://github.com/sixeyed/nerd-dinner) and am using this as the basis of this project. The C# code has not been changed at all from Sixeyed's copy of the code, which is listed as being an original copy of the code.

The intent is to show that using Windows containers it is possible to run code that goes back a few years.

## Requirements

* Visual Studio 2022
* OpenShift Container Platform 4.12+
	* Windows Machine Config Operator installed and working
* Windows 11 Machine with Windows Containers configured

## Building the Container

